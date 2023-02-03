defmodule Wowlr.Logs.Parser do
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
    year = Timex.now |> Map.get(:year)
    time = Timex.to_datetime({{year, month, day}, {hour, min, sec}}, :local)  |> DateTime.to_unix(:millisecond)
    time + mils
  end



  defcombinatorp(nil, string("nil") |> replace(nil))
  defcombinatorp(:integer, integer(min: 1) )
  defcombinatorp(:float, wrap(
    utf8_string([?0..?9], [min: 1])
    |> string(".") |> utf8_string([?0..?9], [min: 1]))
    |> map({List,:to_string, []})
    )
  defcombinator(:version, utf8_string([?0..?9, ?.], [min: 5]) )
  defcombinatorp(:constant, utf8_string([?A..?Z, ?_], [min: 1]))

  defcombinatorp(
    :quoted_string,
    wrap(
      ignore(string("\""))
      |> repeat_while(utf8_char([]), :not_quote)
      |> ignore(string("\""))
    )
    |> map({List, :to_string, []})
  )

  defcombinatorp(
    :flags,
    ignore(string("0x"))
    |> repeat_while(utf8_char([]), :not_terminator)
  )



  defcombinatorp(
    :timestamp,
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
  )

  defcombinatorp(
    :value,
    choice([
      parsec(:nil),
      parsec(:version),
      parsec(:float),
      parsec(:integer),
      parsec(:constant),
      parsec(:quoted_string),
      parsec(:flags),
      parsec(:parens_list)
    ])
  )

  defcombinatorp(
    :list,
    parsec(:value)
    |> repeat(ignore(string(",")) |> parsec(:value))
  )

  defcombinatorp(
    :parens_list,
    wrap(
      ignore(
        string("(")
        |> parsec(:list)
        |> ignore(string(")"))
      )
    )
  )

  defcombinatorp(:eol, ignore(string("\n")))

  defparsec(
    :line,
    parsec(:timestamp)
    |> ignore(string("  "))
    |> parsec(:constant)
    |> ignore(string(","))
    |> parsec(:list)
    |> parsec(:eol)
  )
end
