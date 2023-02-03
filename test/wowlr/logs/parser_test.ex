defmodule Wowlr.Logs.ParserTest do
  test "recognizes timestamp" do
    {:ok, date, _, %{}, _, _} =
      Wowlr.Logs.Parser.line(
        "1/5 16:43:45.443  COMBAT_LOG_VERSION,20,ADVANCED_LOG_ENABLED,1,BUILD_VERSION,10.0.2,PROJECT_ID,1\n"
      )
  end
end
