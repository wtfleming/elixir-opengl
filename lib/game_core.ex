defmodule GameCore do
  @behaviour :wx_object

  @title 'Elixir OpenGL Core'
  @size {600, 600}

  #######
  # API #
  #######
  def start_link() do
    start_link([])
  end

  def start_link(config) do
    :wx_object.start_link(__MODULE__, config, [])
  end

  def load(ref, module) do
    :wx_object.call(ref, {:load, module})
  end

  def unload(ref) do
    :wx_object.call(ref, :unload)
  end

  def shutdown(ref) do
    :wx_object.call(ref, :stop)
  end

  #################################
  # :wx_object behavior callbacks #
  #################################

  def init(config) do
    wx = :wx.new(config)
    Process.flag(:trap_exit, true)
    frame = :wxFrame.new(wx, :wx_const.wx_id_any, @title, [{:size, @size}])
    :wxFrame.show(frame)
    {frame, %{win: frame}}
  end

  def handle_info({:EXIT, _, :normal}, state) do
   {:noreply, state}
  end

  def handle_info({:EXIT, _, :wx_deleted}, state) do
    {:noreply, state}
  end

  def handle_info(msg, state) do
    :io.format("Info: ~p~n", [msg])
    {:noreply, state}
  end


  def handle_call({:load, module}, _from, state) do
    ref = module.start([{:parent, state.win}, {:size, :wxWindow.getClientSize(state.win)}])
    {:reply, ref, Map.put(state, :object, ref)}
  end

  def handle_call(:unload, _from, state) do
    send(:wx_object.get_pid(state.object), :stop)
    {:reply, :ok, Map.put(state, :object, nil)}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, state}
  end

  def handle_call(msg, _from, state) do
    :io.format("Call: ~p~n", [msg])
    {:reply, :ok, state}
  end


  def handle_cast(msg, state) do
    :io.format("Cast: ~p~n", [msg])
    {:noreply, state}
  end

  def handle_event(ev, state) do
    :io.format("~p Event: ~p~n", [__MODULE__, ev])
    {:noreply, state}
  end

  def code_change(_, _, state) do
    {:stop, :not_implemented, state}
  end

  def terminate(_reason, _state) do
    :wx.destroy()
  end


end
