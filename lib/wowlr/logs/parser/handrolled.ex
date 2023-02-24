defmodule Wowlr.Logs.Parser.Handrolled do
  @moduledoc """
  provides functions to parse a single Combatlog line
  see https://wowpedia.fandom.com/wiki/COMBAT_LOG_EVENT for information on the format
  """

  def parse_line(line), do: parse_line(line, Timex.now())

  def parse_line(line, reference_time) when is_binary(line) do
    [time, body] = String.split(line, "  ")

    with {:ok, time} <- parse_timestamp(time, reference_time),
         {:ok, {event, payload}} <- parse_body(body) do
      {:ok, Wowlr.Logs.Parser.Event.from_raw(time, event, payload)}
    end
  end

  defp parse_timestamp(timestamp, reference) do
    # parse a partial log timestamp into a proper one
    # use the reference timestamp to determine the correct year
    # it is assumed that the reference time is before timestamp

    with {:ok, naive_partial} <- Timex.parse(timestamp, "{M}/{D} {h24}:{m}:{s}{ss}"),
         local_partial = Timex.to_datetime(naive_partial) do
      # we parsed the date as utc above because parsing it directly as localtime
      # has weird results (since timezones in the year 0000 are wild)
      # hence, we'll manipulate the date by manually subtracting the offset
      tz = Timex.timezone(Timex.Timezone.Local.lookup(), reference)
      local_partial = DateTime.add(local_partial, -1 * tz.offset_utc, :second)

      parsed =
        case local_partial.month < reference.month do
          true -> %DateTime{local_partial | year: reference.year + 1}
          false -> %DateTime{local_partial | year: reference.year}
        end

      {:ok, Timex.diff(parsed, reference, :milliseconds)}
    end
  end

  defp parse_body(body) do
    [event, rest] = String.split(body, ",", parts: 2)
    {:ok, {event, parse_payload(String.trim_trailing(rest))}}
  end

  def parse_payload(rest) do
    parse_payload(rest, [])
  end

  # End of line
  def parse_payload("", stack) do
    # unwrap stack and return sorted items
    {head, _stack} = pull(stack)
    Enum.reverse(head)
  end

  def parse_payload("nil" <> rest, stack) do
    push_value_and_continue(rest, stack, nil)
  end

  # flags
  def parse_payload("0x" <> _ = rest, stack) do
    [val, rest] = split_at_separator(rest)
    flags = parse_flags(val)
    push_value_and_continue(rest, stack, flags)
  end

  # quoted string
  def parse_payload("\"" <> _ = rest, stack) do
    [val, rest] = split_at_separator(rest)
    push_value_and_continue(rest, stack, String.trim(val, "\""))
  end

  # lists
  def parse_payload("(" <> rest, stack), do: parse_start_of_list(rest, stack)
  def parse_payload("[" <> rest, stack), do: parse_start_of_list(rest, stack)
  def parse_payload(")" <> rest, stack), do: parse_end_of_list(rest, stack)
  def parse_payload("]" <> rest, stack), do: parse_end_of_list(rest, stack)

  defp parse_start_of_list(rest, stack) do
    stack = add_stack(stack)
    parse_payload(rest, stack)
  end

  defp parse_end_of_list(rest, stack) do
    {val, stack} = pull(stack)
    push_value_and_continue(String.trim_leading(rest, ","), stack, Enum.reverse(val))
  end

  # fallthrough case: constants, ints, floats, etc
  def parse_payload(rest, stack) do
    [val, rest] = split_at_separator(rest)
    val = parse_value(val)
    push_value_and_continue(rest, stack, val)
  end

  # utils

  def push_value_and_continue(rest, stack, value) do
    stack = push(stack, value)
    parse_payload(rest, stack)
  end

  def split_at_separator(string) do
    # find first valid delimiter and split on it
    parens_offset =
      case :binary.match(string, ")") do
        {offset, _} -> offset
        :nomatch -> String.length(string)
      end

    bracket_offset =
      case :binary.match(string, "]") do
        {offset, _} -> offset
        :nomatch -> String.length(string)
      end

    comma_offset =
      case :binary.match(string, ",") do
        {offset, _} -> offset
        :nomatch -> String.length(string)
      end

    offset =
      min(parens_offset, comma_offset)
      |> min(bracket_offset)

    {val, rest} = String.split_at(string, offset)

    # remove leading comma from rest to make matching easy
    # we're explicitely keeping the parens
    [val, String.trim_leading(rest, ",")]
  end

  def parse_value(value) do
    int_match = String.match?(value, ~r/^-?\d+$/)
    float_match = String.match?(value, ~r/^-?\d+\.\d+$/)

    case {int_match, float_match} do
      {true, _} -> Integer.parse(value, 10) |> elem(0)
      {_, true} -> Float.parse(value) |> elem(0)
      _ -> value
    end
  end

  defp parse_flags(flags) do
    Integer.parse(String.trim_leading(flags, "0x"), 16)
    |> elem(0)
  end

  # stack helpers

  def push(stack, val) do
    {head, tail} = pull(stack)
    add_stack(tail, [val | head])
  end

  def add_stack(stack, val \\ []) do
    [val | stack]
  end

  def pull(stack) do
    case stack do
      [head | tail] -> {head, tail}
      [] -> {[], []}
    end
  end
end
