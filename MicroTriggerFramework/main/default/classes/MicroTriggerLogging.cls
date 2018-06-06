/**
 * MicroTrigger Framework https://github.com/kofijohnson/Apex-MicroTrigger
 * Copyright (C) 2016  Kofi Johnson (www.kofijohnson.com)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*******************************************************************************************************
* @Description: MicroTrigger Logs Namespace Class.
* @Author: Kofi Johnson - https://github.com/kofijohnson
********************************************************************************************************/

public class MicroTriggerLogging {

    private static Integer nextLogId {
        get {
            if (nextLogId == null) {
                nextLogId = 0;
            }
            return nextLogId ++;
        }
    }

    /*******************************************************************************************************
    * @description Run when a new Log starts. It gets and notifies all the MicroTrigger Listeners.
    * @param LogEvent Contains the information about the Log.
    * @return void
    ********************************************************************************************************/
    public static void emitLogStarted(LogEvent logEvent) {
        for (MicroTriggerLogListener__mdt logListenerMDT :[SELECT ApexClass__c FROM MicroTriggerLogListener__mdt]) {
            LogListener logListener = (LogListener) Type.forName(logListenerMDT.ApexClass__c).newInstance();
            logListener.logStarted(logEvent);
        }
    }

    /*******************************************************************************************************
    * @description Runs when a new Log completes. It gets and notifies all the MicroTrigger Listeners.
    * @param LogEvent Contains the information about the Log.
    * @return void
    ********************************************************************************************************/
    public static void emitLogCompleted(LogEvent logEvent) {
        for (MicroTriggerLogListener__mdt logListenerMDT :[SELECT ApexClass__c FROM MicroTriggerLogListener__mdt]) {
            LogListener logListener = (LogListener) Type.forName(logListenerMDT.ApexClass__c).newInstance();
            logListener.logCompleted(logEvent);
        }
    }

    /*******************************************************************************************************
    * @descripton The interface that all the Listeners should implement. 
    ********************************************************************************************************/
    public interface LogListener {

        /*******************************************************************************************************
        * @description Runs when a new Log starts.
        * @param LogEvent Contains the information about the Log.
        * @return void
        ********************************************************************************************************/
        void logStarted(LogEvent logEvent);

        /*******************************************************************************************************
        * @description Runs when a new Log completes.
        * @param LogEvent Contains the information about the Log.
        * @return void
        ********************************************************************************************************/
        void logCompleted(LogEvent logEvent);
    }

    /*******************************************************************************************************
    * @descripton Contains the information about the Log.
    ********************************************************************************************************/
    public class LogEvent {
        public String logId {get; private set;}
        public String componentName {get; private set;}
        public String componentType {get; private set;}

        /*******************************************************************************************************
        * @description LogEvent Constructor.
        * @param String The name of the Component where the Log started.
        * @param String The type of the Component where the Log started.
        ********************************************************************************************************/
        public LogEvent(String componentName, String componentType) {
            this.logId = String.valueOf(nextLogId);
            this.componentName = componentType == 'Trigger' ? componentName + ' (' + getTriggerEvent() + ')' : componentName;
            this.componentType = componentType;
        }

        /*******************************************************************************************************
        * @description Gets the current trigger event.
        * @return String. Trigger Event.
        ********************************************************************************************************/ 
        private String getTriggerEvent() {
            if(Trigger.isBefore && Trigger.isInsert)
                return 'Before Insert';
            if(Trigger.isAfter && Trigger.isInsert)
                return 'After Insert';
            if(Trigger.isBefore && Trigger.isUpdate)
                return 'Before Update';
            if(Trigger.isAfter && Trigger.isUpdate)
                return 'After Update';
            if(Trigger.isBefore && Trigger.isDelete)
                return 'Before Delete';
            if(Trigger.isAfter && Trigger.isDelete)
                return 'After Delete';
            if(Trigger.isAfter && Trigger.isUndelete)
                return 'After Undelete';

            return '';
        }
    }
}