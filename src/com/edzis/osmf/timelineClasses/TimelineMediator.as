package com.edzis.osmf.timelineClasses {
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import org.osmf.events.TimeEvent;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	[ExcludeClass]
	/**
	 * Controls the playback of a MovieClip in relation to SEEK and PLAY traits
	 * Accepts a specific frameRate that is used to calculate duration and maintain playback synchronization
	 */
	public class TimelineMediator extends EventDispatcher {
		
		public var currentTime		:Number = 0;
		public var duration			:Number;
		public var playTrait		:PlayTrait;
		
		private var mc				:ITimeline;
		private var frameRate		:Number;
		private var targetTime		:Number = 0;
		private var startTimestamp	:Number;
		private var ticker			:Shape = new Shape();

		
		public function TimelineMediator(mc:ITimeline, frameRate:Number = 30) {
			this.mc = mc;
			this.frameRate = frameRate;
			duration = mc.frameCount/frameRate;
		}
		
		/**
		 * Opens up a way for PLAY trait to start playing
		 */
		public function startPlayback():void {
			startTimestamp = getTimer()/1000 - targetTime;
			startTick();
		}
		
		/**
		 * Opens up a way for PLAY trait to stop playing
		 */
		public function stopPlayback():void {
			stopTick();
		}
		
		/**
		 * Opens up a way for SEEK trait to update playhead
		 */
		public function seekPlayback(time:Number):void {
			// ignore seek value in case of looping, rely instead on targetTime value calculated when reaching the end
			// this is needed because maybe some frames must be skipped at the end and begining to sustain smooth looping
			if(currentTime == duration && time == 0 && playTrait.playState == PlayState.PLAYING) {
				renderTime(targetTime);
				startTick();
				return;
			}
				
			targetTime = time;
			renderTime(targetTime);
			
			// if playing, must also update startTimestamp to make preceeding frames correct
			if(playTrait.playState == PlayState.PLAYING)
				startTimestamp = getTimer()/1000 - currentTime;
		}
		
		private function startTick():void {
			ticker.addEventListener(Event.ENTER_FRAME, updateTime);
		}
		
		private function stopTick():void {
			ticker.removeEventListener(Event.ENTER_FRAME, updateTime);
		}
		
		
		/**
		 * Advance the targetTime value by cheching the delta between getTimer() and startTimestamp
		 * Also handle the end of timeline
		 */
		private function updateTime(e:Event):void {
			targetTime = getTimer()/1000 - startTimestamp;
			if(targetTime >= duration){// reached the end
				// mentally roll one loop forward:
				startTimestamp += duration; // as if the first frame was rendered one loop later
				targetTime -= duration; // as if the distance from first frame is one loop shorter
				
				renderTime(duration); // go to the end of visuals and currentTime value, in case no looping happens
				signalComplete(); // signal that the end was reached
			} else
				renderTime(targetTime);
		}
		
		/**
		 * Finds the corresponding frame for a particular time value and goes to it
		 */
		private function renderTime(time:Number):void {
			currentTime = time;
			var newFrame:uint = Math.floor(frameRate * time);
			if(newFrame == mc.frameCount)
				newFrame-=1;
			if(mc.frameIndex != newFrame)
				mc.renderFrame(newFrame);
		}
		
		/**
		 * Mimics signalComplete() method of TimeTrait
		 */
		private function signalComplete():void {
			dispatchEvent(new TimeEvent(TimeEvent.COMPLETE));
		}
	}
}