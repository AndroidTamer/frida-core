namespace Zed {
	namespace Agent {
		private static WinIpc.ClientProxy proxy;

		private static Zed.FuncTracer func_tracer;
		private static Zed.GstTracer gst_tracer;

		public void main (string ipc_server_address) {
			var loop = new MainLoop ();

			proxy = new WinIpc.ClientProxy (ipc_server_address);
			proxy.add_notify_handler ("Stop", "", (arg) => {
				loop.quit ();
			});

			Idle.add (() => {
				do_establish (proxy);
				return false;
			});

			loop.run ();

			if (gst_tracer != null) {
				gst_tracer.detach ();
				gst_tracer = null;
			}

			if (func_tracer != null) {
				func_tracer.detach ();
				func_tracer = null;
			}
		}

		private async void do_establish (WinIpc.ClientProxy proxy) {
			try {
				yield proxy.establish ();
			} catch (WinIpc.ProxyError e) {
				error (e.message);
				return;
			}

			func_tracer = new Zed.FuncTracer (proxy);
			func_tracer.attach ();

			gst_tracer = new Zed.GstTracer (proxy);
			gst_tracer.attach ();
		}
	}
}
