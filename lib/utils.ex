defmodule Wowlr.SpecToCallback do
  def __on_definition__(env, :def, name, args, _guards, _body) do
    Module.spec_to_callback(env.module, {name, length(args)})
  end

  def __on_definition__(_, _, _, _, _, _), do: nil
end
