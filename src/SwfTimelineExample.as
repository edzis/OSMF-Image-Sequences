package {
	import com.bit101.components.HSlider;
	import com.bit101.components.HUISlider;
	import com.bit101.components.PushButton;
	import com.edzis.osmf.timelineClasses.SwfTimeline;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	[SWF(width="768", height="636", frameRate="30")]
	public class SwfTimelineExample extends MediaPlayerSprite {

		private var url:String = "ball.swf";

		private var btns:Sprite;
		private var scrollBar:HSlider;
		private var frameRateSlider:HUISlider;
		private var lastSeekRatio:Number;
		
		public function SwfTimelineExample()
		{
			stage.scaleMode = "noScale";
			stage.align = "lt";
			
			// workaround for a relative path to work online
			var swfURL:String = this.loaderInfo.url;
			swfURL = swfURL.substr(0, swfURL.lastIndexOf("/") + 1);
			url = swfURL + url;
			
			
		//	PLAYER
			mediaPlayer.autoPlay = true;
			mediaPlayer.loop = true;
			scaleMode = ScaleMode.NONE;
			
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, updateTime);
			mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, updateDuration);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, applyNewSeek);
			mediaPlayer.currentTimeUpdateInterval = 1;
			
			
		//	UI
			btns = new Sprite();
			btns.x = 10;
			addChild(btns);
			
			var playBtn:PushButton = new PushButton(btns, 0, 0, "PLAY", play);
			playBtn.width = 40;
			
			var pauseBtn:PushButton = new PushButton(btns, 50, 0, "PAUSE", pause);
			pauseBtn.width = 40;
			
			scrollBar = new HSlider(btns, 100, 5, seek);
			scrollBar.minimum = 0;
			scrollBar.maximum = 0;
			scrollBar.value = 0;
			scrollBar.width = 280;
			
			frameRateSlider = new HUISlider(btns, 0, 25, "FRAMERATE", resetMedia);
			frameRateSlider.minimum = 1;
			frameRateSlider.maximum = 150;
			frameRateSlider.value = 30;
			frameRateSlider.tick = 1;
			frameRateSlider.width = 300;
			frameRateSlider.labelPrecision = 0;
			resetMedia();
			
			
		//	RESIZE
			stage.addEventListener(Event.RESIZE, onResize);
			onResize(null);
		}
		
		
	//	UI TO PLAYER
		private function resetMedia(e:Event = null):void {
			if(mediaPlayer.duration > 0)
				lastSeekRatio = mediaPlayer.currentTime / mediaPlayer.duration;
			var resource:URLResource = new URLResource(url);
			resource.addMetadataValue("frameRate", frameRateSlider.value);
			media = new SwfTimeline(resource);
		}
		
		private function play(e:Event = null):void {
			mediaPlayer.play();
		}
		
		private function pause(e:Event = null):void {
			mediaPlayer.pause();
		}
		
		private function seek(e:Event = null):void {
			mediaPlayer.seek(scrollBar.value);
		}
		
		protected function applyNewSeek(event:MediaPlayerCapabilityChangeEvent):void {
			if(event.enabled && !isNaN(lastSeekRatio))
				mediaPlayer.seek(lastSeekRatio*mediaPlayer.duration);
		}
		
		
	//	PLAYER TO UI
		protected function onResize(event:Event):void {
			width = stage.stageWidth;
			height = stage.stageHeight - 60;
			btns.y = stage.stageHeight - 50;
			scrollBar.width = stage.stageWidth - scrollBar.x - 20;
			frameRateSlider.x = stage.stageWidth - frameRateSlider.width - 20 + 35;
		}
		
		protected function updateTime(event:TimeEvent):void {
			scrollBar.value = mediaPlayer.currentTime;
		}
		
		protected function updateDuration(event:TimeEvent):void {
			scrollBar.maximum = mediaPlayer.duration;
		}
		
	}
}