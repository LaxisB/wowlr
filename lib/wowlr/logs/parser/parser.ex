defmodule Wowlr.Logs.Parser do
  alias Wowlr.Logs.Parser

  defdelegate parse_line(line), to: Parser.Handrolled
  defdelegate parse_line(line, time), to: Parser.Handrolled
  defdelegate parse_value(line), to: Parser.Handrolled
end
