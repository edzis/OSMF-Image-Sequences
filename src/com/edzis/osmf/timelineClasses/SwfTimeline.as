package com.edzis.osmf.timelineClasses
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.SWFLoader;
	import org.osmf.media.URLResource;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * Extends SWFElement to be more like videos - adds TIME, SEEK and PLAY traits
	 * Also accepts a specific frameRate in the form of resource metadata that is used when advancing the playhead and determining duration
	 * 	resource.addMetadataValue("frameRate", 24);
	 */
	public class SwfTimeline extends SWFElement implements ITimeline
	{
		private var timeline			:MovieClip;
		private var timelineMediator	:TimelineMediator;
		
		
		
		public function SwfTimeline(resource:URLResource=null, loader:SWFLoader=null) {
			super(resource, loader);
		}
		
		/**
		 * Set up everything to use the loaded content
		 */
		override protected function processReadyState():void {
			super.processReadyState();
			
			var displayObjectTrait:DisplayObjectTrait = getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			var loader:Loader = displayObjectTrait.displayObject as Loader;
			timeline = loader.content as MovieClip;
			if(!timeline)
				return;
			
			timeline.gotoAndStop(1);
			if(timeline.totalFrames > 1)
				addTraits();
		}
		
		/**
		 * Prepare for garbage collection
		 */
		override protected function processUnloadingState():void {
			if(hasTrait(MediaTraitType.PLAY)) {
				removeTrait(MediaTraitType.PLAY);
				removeTrait(MediaTraitType.SEEK);
				removeTrait(MediaTraitType.TIME);
			}
			timeline = null;
			super.processUnloadingState();
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
			return timeline.currentFrame-1;;
		}
		
		public function get frameCount():int {
			return timeline.totalFrames;
		}
		
		public function renderFrame(frameIndex:uint):void {
			timeline.gotoAndStop(frameIndex+1);
		}


	}
}