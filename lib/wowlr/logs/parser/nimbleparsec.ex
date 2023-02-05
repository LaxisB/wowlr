defmodule Wowlr.Logs.Parser.NimbleParsec do
  import NimbleParsec

  def not_comma(<<?,, _::binary>>, context, _, _), do: {:halt, context}
  def not_comma(_, context, _, _), do: {:cont, context}
  def not_quote(<<?", _::binary>>, context, _, _), do: {:halt, context}
  def not_quote(_, context, _, _), do: {:cont, context}
  def not_terminator(<<",", _::binary>>, context, _, _), do: {:halt, context}
  def not_terminator(<<"(", _::binary>>, context, _, _), do: {:halt, context}
  def not_terminator(<<"[", _::binary>>, context, _, _), do: {:halt, context}
  def not_terminator(<<")", _::binary>>, context, _, _), do: {:halt, context}
  def not_terminator(<<"]", _::binary>>, context, _, _), do: {:halt, context}
  def not_terminator(_, context, _, _), do: {:cont, context}

  def as_datetime([month, day, hour, min, sec, mils]) do
    year = Timex.now() |> Map.get(:year)

    time =
      Timex.to_datetime({{year, month, day}, {hour, min, sec}}, :local)
      |> DateTime.to_unix(:millisecond)

    time + mils
  end

  def as_int(string) do
    Integer.parse(string, 10)
    |> elem(0)
  end

  def as_float(string) do
    Float.parse(string)
    |> elem(0)
  end

  defcombinatorp nil, string("nil") |> replace(nil)

  defcombinatorp :integer, utf8_string([?-, ?0..?9], min: 1) |> map({__MODULE__, :as_int, []})

  defcombinatorp :float,
                 wrap(
                   utf8_string([?-, ?0..?9], min: 1)
                   |> string(".")
                   |> utf8_string([?0..?9], min: 1)
                 )
                 |> map({List, :to_string, []})

  defcombinator :version, utf8_string([?0..?9, ?.], min: 5)
  defcombinatorp :constant, utf8_string([?A..?Z, ?_], min: 1)

  defcombinatorp :quoted_string,
                 wrap(
                   ignore(string("\""))
                   |> repeat_while(utf8_char([]), :not_quote)
                   |> ignore(string("\""))
                 )
                 |> map({List, :to_string, []})

  defcombinatorp :flags,
                 wrap(
                   ignore(string("0x"))
                   |> utf8_string([?0..?0, ?A..?F], min: 1)
                 )

  defcombinatorp :guid,
                 wrap(
                   choice([
                     string("BattlePet"),
                     string("BNetAccount"),
                     string("Cast"),
                     string("ClientActor"),
                     string("Creature"),
                     string("Follower"),
                     string("Item"),
                     string("Player"),
                     string("Vignette")
                   ])
                   |> repeat(string("-") |> utf8_string([?0..?9, ?A..?F], min: 1))
                 )
                 |> map({List, :to_string, []})

  defcombinatorp :timestamp,
                 wrap(
                   choice([integer(2), integer(1)])
                   |> ignore(string("/"))
                   |> choice([integer(2), integer(1)])
                   |> ignore(string(" "))
                   |> choice([integer(2), integer(1)])
                   |> ignore(string(":"))
                   |> choice([integer(2), integer(1)])
                   |> ignore(string(":"))
                   |> choice([integer(2), integer(1)])
                   |> ignore(string("."))
                   |> choice([integer(3), integer(2), integer(1)])
                 )
                 |> map({__MODULE__, :as_datetime, []})

  defcombinatorp :value,
                 choice([
                   parsec(nil),
                   parsec(:flags),
                   parsec(:guid),
                   parsec(:constant),
                   parsec(:quoted_string),
                   parsec(:version),
                   parsec(:float),
                   parsec(:integer),
                   parsec(:empty_list),
                   parsec(:parens_list),
                   parsec(:bracket_list)
                 ])

  defcombinatorp :list,
                 parsec(:value)
                 |> repeat(ignore(string(",")) |> parsec(:value))

  defcombinatorp :empty_list,
                 choice([
                   string("()"),
                   string("[]")
                 ])
                 |> replace([])

  defcombinatorp :parens_list,
                 wrap(
                   ignore(
                     string("(")
                     |> parsec(:list)
                     |> ignore(string(")"))
                   )
                 )

  defcombinatorp :bracket_list,
                 wrap(
                   ignore(
                     string("[")
                     |> parsec(:list)
                     |> ignore(string("]"))
                   )
                 )

  defcombinatorp :eol, ignore(string("\n"))

  defparsec :parse_line,
            parsec(:timestamp)
            |> ignore(string("  "))
            |> parsec(:constant)
            |> ignore(string(","))
            |> parsec(:list)
            |> parsec(:eol)

  defparsec :parse_value, parsec(:value)
end
