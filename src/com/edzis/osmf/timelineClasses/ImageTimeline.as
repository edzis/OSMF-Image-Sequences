package com.edzis.osmf.timelineClasses {
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class ImageTimeline extends MediaElement implements ITimeline
	{
		private var frames				:Vector.<ImageElement> = new Vector.<ImageElement>();
		private var timelineMediator	:TimelineMediator;
		private var frame				:int;
		private var urlResource			:URLResource;

		private var currentImage		:ImageElement;
		private var displayTrait		:TimelineDisplayTrait;
		
		public function ImageTimeline(resource:URLResource=null) {
			super();
			if(resource != null)
				this.resource = resource;
		}
		
		/**
		 * Check if the url can be used
		 */
		public function canHandleResource(resource:MediaResourceBase):Boolean {
			var imageLoader:ImageLoader = new ImageLoader();
			var validImageURL:Boolean = imageLoader.canHandleResource(resource);
			
			if (validImageURL){
				var urlResource:URLResource = resource as URLResource;
				// contains some text or symbols, ends with one or more numbers before the extension
				// for example http://www.example.com/somefolder/imagename42.jpeg
				return (urlResource.url.search(/(.*(\/|_))([0-9]+)(\..*)/i) != -1);
			}	
			return false;
		}
		
		/**
		 * Requires a URLResorce with the url of the last frame
		 */
		override public function set resource(value:MediaResourceBase):void {
			if(frames.length > 0)
				return; // allready initialized
			
			urlResource = value as URLResource;
			if (urlResource.url == null)
				throw( new Error(this + " requires resource to be a URLResource with url set " + urlResource));
			
			buildContent(urlResource.url);
			if(frames.length > 1)
				addTraits();
			currentImage = frames[0];
		}
		
		override public function get resource():MediaResourceBase {
			return urlResource;
		}
		
		
		/**
		 * Creates imageElements for each frame, but does not load them
		 */
		private function buildContent(url:String):void {
			var urlParts:Array = url.match(/(.*(\/|_))([0-9]+)(\..*)/i);
			var urlBase:String = urlParts[1];
			var frameCount:int = int(urlParts[3]);
			var urlFrameLength:int = urlParts[3].length;
			var urlExtension:String = urlParts[4];
			
			if(frames.length > 0) return;
			for(var i:int = 0; i < frameCount; i++) {
				url = urlBase;
				var frameIndexString:String = (i + 1).toString();
				while(frameIndexString.length < urlFrameLength)
					frameIndexString = "0" + frameIndexString;
				url += frameIndexString + urlExtension;
				frames[i] = new ImageElement(new URLResource(url));
			};
		}
		
		/**
		 * Creates and adds the 3 basic traits that make the element video-alike - TIME, SEEK and PLAY
		 * These open a way to outer world to controll the timeline.
		 * However the real control is executed by TimelineMediator that reacts to changes in traits
		 */
		private function addTraits():void {
			var frameRate:Number = resource.getMetadataValue("frameRate") as Number;
			
			timelineMediator = new TimelineMediator(this, frameRate);
			
			var timeTrait:TimelineTimeTrait = new TimelineTimeTrait(timelineMediator.duration, timelineMediator);
			var seekTrait:TimelineSeekTrait = new TimelineSeekTrait(timeTrait, timelineMediator);
			var playTrait:TimelinePlayTrait = new TimelinePlayTrait(timelineMediator);
			
			timelineMediator.playTrait = playTrait;
			
			addTrait(MediaTraitType.TIME, timeTrait);
			addTrait(MediaTraitType.SEEK, seekTrait);
			addTrait(MediaTraitType.PLAY, playTrait);
		}
		
		
		public function get frameIndex():int {
			return frame;
		}
		
		public function get frameCount():int {
			return frames.length;
		}
		
		public function renderFrame(frameIndex:uint):void {
			if(currentImage == frames[frameIndex])
				return;
			frame = frameIndex;
			
			// OLD ELEMENT
			if(currentImage)
				currentImage.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdded);
			
			
			//	NEW ELEMENT
			currentImage = frames[frameIndex];
			currentImage.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdded);
			addCurrentImage();
			var loadTrait:LoadTrait = currentImage.getTrait(MediaTraitType.LOAD) as LoadTrait;
			if(loadTrait.loadState == LoadState.UNINITIALIZED)
				loadTrait.load();
		}
		
		/**
		 * Checks if currentImage has received a new DisplatObjectTrait, to be used for 
		 */
		private function onTraitAdded(event:MediaElementEvent):void {
			if(event.traitType == MediaTraitType.DISPLAY_OBJECT && event.target == currentImage)
				addCurrentImage();
		}
		
		/**
		 * Sets the new displayObject. Called only when the currentImages has finished loading and has receivet it's own DisplatObjectTrait
		 */
		private function addCurrentImage():void {
			var currentDisplayTrait:DisplayObjectTrait = currentImage.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			if(!currentDisplayTrait)
				return;
			
			if(!displayTrait){
				displayTrait = new TimelineDisplayTrait(currentDisplayTrait.displayObject, currentDisplayTrait.mediaWidth, currentDisplayTrait.mediaHeight);
				addTrait(MediaTraitType.DISPLAY_OBJECT, displayTrait);
			} else
				displayTrait.displayObject = currentDisplayTrait.displayObject;
			
		}
		
	}
}