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
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	[ExcludeClass]
	
	public class TimelinePlayTrait extends PlayTrait
	{
		
		public function TimelinePlayTrait(mediator:TimelineMediator)
		{
			super();
			this.mediator = mediator;
		}
		
		/**
		 * Execute the playState change on TimelineMediator
		 */
		override protected function playStateChangeStart(newPlayState:String):void
		{
			if(newPlayState == PlayState.PLAYING)
				mediator.startPlayback();
			else
				mediator.stopPlayback();
			super.playStateChangeStart(newPlayState);
		}
		
		
		private var mediator		:TimelineMediator;
	}
}