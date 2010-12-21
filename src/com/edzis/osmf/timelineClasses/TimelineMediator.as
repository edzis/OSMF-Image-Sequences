package com.edzis.osmf.timelineClasses {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import org.osmf.events.TimeEvent;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	/**
	 * Controls the playback of a MovieClip in relation to SEEK and PLAY traits
	 * Accepts a specific fps that is used to calculate duration and maintain playback synchronization
	 */
	public class TimelineMediator extends EventDispatcher {
		
		public var currentTime		:Number = 0;
		public var duration			:Number;
		public var playTrait		:PlayTrait;
		
		private var mc				:MovieClip;
		private var fps				:Number;
		private var targetTime		:Number = 0;
		private var startTimestamp	:Number;

		
		public function TimelineMediator(mc:MovieClip, fps:Number = 30) {
			this.mc = mc;
			this.fps = fps;
			duration = mc.totalFrames/fps;
		}
		
		/**
		 * Opens up a way for PLAY trait to start playing
		 */
		public function startPlayback():void {
			startTimestamp = getTimer()/1000 - targetTime;
			mc.addEventListener(Event.ENTER_FRAME, updateTime);
		}
		
		/**
		 * Opens up a way for PLAY trait to stop playing
		 */
		public function stopPlayback():void {
			mc.removeEventListener(Event.ENTER_FRAME, updateTime)
		}
		
		/**
		 * Opens up a way for SEEK trait to update playhead
		 */
		public function seekPlayback(time:Number):void {
			// ignore seek value in case of looping, rely instead on targetTime value calculated when reaching the end
			// this is needed because maybe some frames must be skipped at the end and begining to sustain smooth looping
			if(currentTime == duration && time == 0 && playTrait.playState == PlayState.PLAYING) {
				render(targetTime);
				mc.addEventListener(Event.ENTER_FRAME, updateTime);
				return;
			}
				
			targetTime = time;
			render(targetTime);
			
			// if playing, must also update startTimestamp to make preceeding frames correct
			if(playTrait.playState == PlayState.PLAYING)
				startTimestamp = getTimer()/1000 - currentTime;
		}
		
		
		/**
		 * Advance the targetTime value by cheching the delta between getTimer() and startTimestamp
		 * Also handle the end of timeline
		 */
		private function updateTime(e:Event):void {
			targetTime = getTimer()/1000 - startTimestamp;
			if(targetTime >= duration){// reached the end
				// mentally roll one loop forward:
				startTimestamp += duration; // the first frame was rendered one frame later
				targetTime -= duration; // the distance from first frame is oneloop shorter
				render(duration); // go to the end of visuals and currentTime value, in case no looping happens
				signalComplete(); // signal that the end was reached
			} else
				render(targetTime);
		}
		
		/**
		 * Finds the corresponding frame for a particular time value and goes to it
		 */
		private function render(time:Number):void {
			currentTime = time;
			var newFrame:uint = Math.floor(fps * time) + 1;
			if(mc.currentFrame != newFrame)
				mc.gotoAndStop(newFrame);
		}
		
		/**
		 * Mimics signalComplete() method of TimeTrait
		 */
		private function signalComplete():void {
			dispatchEvent(new TimeEvent(TimeEvent.COMPLETE));
		}
	}
}