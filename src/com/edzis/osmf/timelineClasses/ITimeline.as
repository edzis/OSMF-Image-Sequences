package com.edzis.osmf.timelineClasses {
	public interface ITimeline {
		
		function get frameIndex():uint
		function get frameCount():uint
		function renderFrame(frameIndex:uint):void
	}
}