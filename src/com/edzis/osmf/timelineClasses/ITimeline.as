package com.edzis.osmf.timelineClasses {
	public interface ITimeline {
		
		function get frameIndex():int
		function get frameCount():int
		function renderFrame(frameIndex:uint):void
	}
}