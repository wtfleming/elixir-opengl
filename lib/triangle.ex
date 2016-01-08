defmodule Triangle do
  @behaviour :wx_object
  use Bitwise

  #######
  # API #
  #######
  def start(config) do
    :wx_object.start_link(__MODULE__, config, [])
  end

  #################################
  # :wx_object behavior callbacks #
  #################################
  def init(config) do
    parent = :proplists.get_value(:parent, config)
    size = :proplists.get_value(:size, config)

    opts = [{:size, size}]
    gl_attrib = [{:attribList, [:wx_const.wx_gl_rgba,
                                :wx_const.wx_gl_doublebuffer,
                                :wx_const.wx_gl_min_red, 8,
                                :wx_const.wx_gl_min_green, 8,
                                :wx_const.wx_gl_min_blue, 8,
                                :wx_const.wx_gl_depth_size, 24, 0]}]

    canvas = :wxGLCanvas.new(parent, opts ++ gl_attrib)
    :wxGLCanvas.connect(canvas, :size)
    :wxWindow.hide(parent)
    :wxWindow.reparent(canvas, parent)
    :wxWindow.show(parent)
    :wxGLCanvas.setCurrent(canvas)
    setup_gl(canvas)

    # Periodically send a message to trigger a redraw of the scene
    timer = :timer.send_interval(20, self(), :update)

    {parent, %{canvas: canvas, timer: timer}}
  end

  def code_change(_, _, state) do
    {:stop, :not_implemented, state}
  end

  def handle_cast(msg, state) do
    :io.format("Cast: ~p~n", [msg])
    {:noreply, state}
  end

  def handle_call(msg, _from, state) do
    :io.format("Call: ~p~n", [msg])
    {:reply, :ok, state}
  end

  def handle_info(:stop, state) do
    :timer.cancel(state.timer)
    :wxGLCanvas.destroy(state.canvas)
    {:stop, :normal, state}
  end

  def handle_info(:update, state) do
    :wx.batch(fn -> render(state) end)
    {:noreply, state}
  end

  def handle_event({:wx, _, _, _, {:wxSize, :size, {width, height}, _}}, state) do
    if width != 0 and height != 0 do
      resize_gl_scene(width, height)
    end
    {:noreply, state}
  end

  def terminate(_reason, state) do
    :timer.cancel(state.timer)
    :wxGLCanvas.destroy(state.canvas)
    :timer.sleep(300)
  end


  #####################
  # Private Functions #
  #####################
  defp setup_gl(win) do
    {w, h} = :wxWindow.getClientSize(win)
    resize_gl_scene(w, h)
    :gl.shadeModel(:gl_const.gl_smooth)
    :gl.clearColor(0.0, 0.0, 0.0, 0.0)
    :gl.clearDepth(1.0)
    :gl.enable(:gl_const.gl_depth_test)
    :gl.depthFunc(:gl_const.gl_lequal)
    :gl.hint(:gl_const.gl_perspective_correction_hint, :gl_const.gl_nicest)
    :ok
  end

  defp resize_gl_scene(width, height) do
    :gl.viewport(0, 0, width, height)
    :gl.matrixMode(:gl_const.gl_projection)
    :gl.loadIdentity()
    :glu.perspective(45.0, width / height, 0.1, 100.0)
    :gl.matrixMode(:gl_const.gl_modelview)
    :gl.loadIdentity()
    :ok
  end

  defp draw() do
    :gl.clear(Bitwise.bor(:gl_const.gl_color_buffer_bit, :gl_const.gl_depth_buffer_bit))
    :gl.loadIdentity()
    :gl.translatef(-1.5, 0.0, -6.0)
    :gl.'begin'(:gl_const.gl_triangles)
    :gl.vertex3f(0.0, 1.0, 0.0)
    :gl.vertex3f(-1.0, -1.0, 0.0)
    :gl.vertex3f(1.0, -1.0, 0.0)
    :gl.'end'()
    :ok
  end

  defp render(%{canvas: canvas} = _state) do
    draw()
    :wxGLCanvas.swapBuffers(canvas)
    :ok
  end
end

