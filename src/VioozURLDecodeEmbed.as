package
{
	import flash.desktop.NativeApplication;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	public class VioozURLDecodeEmbed extends Sprite
	{	
		[Embed(source="binary1.swf", mimeType="application/octet-stream")]
		private var storyClass:Class;						
		
		private var iloaded:Object = null;
		private var stringsToDecode:Array = [];
		public function VioozURLDecodeEmbed()
		{
			//stringsToDecode.push("401717b4c50d526fb6a6cc19150c106ed1a554c1c124ad58ceba26032b973e3672c57598cd98bad8017ea858f7d74680e5af8473515c59b79950f2d6b747dafd");
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
		}		
		
		private function onInvoke(evt:InvokeEvent):void {
			if (evt.arguments.length > 0) {
				for each(var string:String in evt.arguments) {
					stringsToDecode.push(string);
				}
			}
			tostring();
		}
						
		public function tostring():void {
			if (!stringsToDecode.length) {
				NativeApplication.nativeApplication.exit();
				return;
			}			
			
			if (!iloaded) {				
				var bytearray:ByteArray = (ByteArray)(new storyClass);				
				var loader:Loader = new Loader();
				var context:LoaderContext = new LoaderContext();
				context.allowCodeImport = true;
				
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
				loader.loadBytes(bytearray, context);
				return;
			}			
			var stringToDecode:String = stringsToDecode.shift();
			var afterSplit:Array = stringToDecode.split("*");
			stringToDecode = afterSplit.length > 1?afterSplit[1]:afterSplit[0];
			
			traceToStdout(iloaded.tostring(stringToDecode));
			tostring();
		}					
		
		private function onLoaded(evt:Event):void {
			this.iloaded = evt.target.content;
			this.tostring();
		}
		
		private function traceToStdout(... traceArgs):void {
			trace(traceArgs);
			try {
				var stdout : FileStream = new FileStream();
				stdout.open(new File("/dev/stdout"), FileMode.WRITE);
				var mesg:String = '';
				for each(var submesg:String in traceArgs) {
					mesg += " "+submesg;
				}
				mesg += "\n";
				stdout.writeUTFBytes(mesg);
				stdout.close();
			} catch (e:Error) {
				
			}
		}		
	}
}