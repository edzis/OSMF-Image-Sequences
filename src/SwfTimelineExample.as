package {
	import com.bit101.components.ComboBox;
	import com.bit101.components.HSlider;
	import com.bit101.components.HUISlider;
	import com.bit101.components.PushButton;
	import com.edzis.osmf.timelineClasses.ImageTimeline;
	import com.edzis.osmf.timelineClasses.SwfTimeline;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osmf.elements.SWFLoader;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	
	[SWF(width="768", height="636", frameRate="30")]
	public class SwfTimelineExample extends MediaPlayerSprite {

		private var content		:Array = [
			{url:"elf/72.jpg", label:"ImageSequence"},
			{url:"ball.swf", label:"Swf sequence"}
		];

		private var btns:Sprite;
		private var scrollBar:HSlider;
		private var frameRateSlider:HUISlider;
		private var lastSeekRatio:Number;

		private var contentSelector:ComboBox;

		private var wasPlaying:Boolean;
		
		public function SwfTimelineExample()
		{
			stage.scaleMode = "noScale";
			stage.align = "lt";
			
			// workaround for a relative path to work online
			var rootUrl:String = this.loaderInfo.url;
			rootUrl = rootUrl.substr(0, rootUrl.lastIndexOf("/") + 1);
			for (var i:int = 0; i < content.length; i++) {
				content[i].url = rootUrl + content[i].url;
			}
			
			
		//	PLAYER
			mediaPlayer.autoPlay = false;
			mediaPlayer.loop = true;
			scaleMode = ScaleMode.NONE;
			
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, updateScrollbar);
			mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, updateScrollbar);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, applyLastValues);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, applyLastValues);
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE, applyLastValues);
			mediaPlayer.currentTimeUpdateInterval = 1;
			
			mediaFactory.addItem
			( new MediaFactoryItem
				( "com.edzis.osmf.imagetimeline"
					, new ImageTimeline().canHandleResource
					, function():MediaElement
					{
						return new ImageTimeline()
					}
				)
			);
			
			mediaFactory.addItem
			( new MediaFactoryItem
				( "com.edzis.osmf.swfTimeline"
					, new SWFLoader().canHandleResource
					, function():MediaElement
					{
						return new SwfTimeline()
					}
				)
			);
			
			
		//	UI
			btns = new Sprite();
			btns.x = 10;
			addChild(btns);
			
			contentSelector = new ComboBox(btns, 0, 0, "Content", content);
			contentSelector.openPosition = "top";
			contentSelector.numVisibleItems = content.length;
			contentSelector.selectedIndex = 0;
			contentSelector.addEventListener(Event.SELECT, resetMedia);
			
			var playBtn:PushButton = new PushButton(btns, 110, 0, "PLAY", play);
			playBtn.width = 40;
			
			var pauseBtn:PushButton = new PushButton(btns, 160, 0, "PAUSE", pause);
			pauseBtn.width = 40;
			
			scrollBar = new HSlider(btns, 210, 5, seek);
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
			trace("resetMedia");
			wasPlaying = mediaPlayer.playing;
			if(mediaPlayer.duration > 0)
				lastSeekRatio = mediaPlayer.currentTime / mediaPlayer.duration;
			var resource:URLResource = new URLResource(contentSelector.selectedItem.url);
			resource.addMetadataValue("frameRate", frameRateSlider.value);
			media = mediaFactory.createMediaElement(resource);
				
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
		
		protected function applyLastValues(event:MediaPlayerCapabilityChangeEvent):void {
			if(!(mediaPlayer.canSeek && mediaPlayer.canPlay && mediaPlayer.temporal))
				return;
			if(event.enabled && !isNaN(lastSeekRatio))
				mediaPlayer.seek(lastSeekRatio*mediaPlayer.duration);
			if(wasPlaying)
				mediaPlayer.play();
			updateScrollbar(null);
		}
		
		
	//	PLAYER TO UI
		protected function onResize(event:Event):void {
			width = stage.stageWidth;
			height = stage.stageHeight - 60;
			btns.y = stage.stageHeight - 50;
			scrollBar.width = stage.stageWidth - scrollBar.x - 20;
			frameRateSlider.x = stage.stageWidth - frameRateSlider.width - 20 + 35;
		}
		
		protected function updateScrollbar(event:TimeEvent):void {
			scrollBar.maximum = mediaPlayer.duration;
			scrollBar.value = mediaPlayer.currentTime;
		}
		
	}
}