package com.edzis.osmf.timelineClasses {
	import flash.display.DisplayObject;
	
	import org.osmf.traits.DisplayObjectTrait;
	
	public class TimelineDisplayTrait extends DisplayObjectTrait {
		public function TimelineDisplayTrait(displayObject:DisplayObject, mediaWidth:Number=0, mediaHeight:Number=0)
		{
			super(displayObject, mediaWidth, mediaHeight);
		}
		
		public function set displayObject(value:DisplayObject):void {
			setDisplayObject(value);
		}
	}
}