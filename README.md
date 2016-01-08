# ElixirOpengl

Example of working with OpenGL from Elixir


Triangle:

![alt tag](https://raw.github.com/wtfleming/elixir-opengl/master/readme-images/triangle.png)

## Run the example

Start iex:

```sh
$ iex -S mix
```

Run the example:

```elixir
iex(1)> gc = GameCore.start_link()
iex(2)> GameCore.load(gc, Triangle)
iex(3)> GameCore.unload(gc)
```

Adapted from Erlang code at https://github.com/asceth/nehe_erlang
