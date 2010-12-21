/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package com.edzis.osmf.timelineClasses
{
	import flash.events.Event;
	
	import org.osmf.events.TimeEvent;
	import org.osmf.traits.TimeTrait;
	
	[ExcludeClass]
	public class TimelineTimeTrait extends TimeTrait
	{

		private var mediator:TimelineMediator;
		
		public function TimelineTimeTrait(duration:Number, mediator:TimelineMediator) {
			super(duration);
			mediator.addEventListener(TimeEvent.COMPLETE, onComplete);
			this.mediator = mediator;
		}
		
		override public function dispose():void {
			mediator.removeEventListener(TimeEvent.COMPLETE, onComplete);
		}
		
		/**
		 * Use TimelineMediator for currentTime
		 */
		override public function get currentTime():Number {
			return mediator.currentTime;
		}
		
		/**
		 * Recieves signalComplete from TimelineMediator
		 */
		protected function onComplete(event:Event):void {
			signalComplete();
		}
		
	}
}