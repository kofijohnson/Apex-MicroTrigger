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
* @Description: Result (report), after a MicroTrigger runs
* @Author: Kofi Johnson - https://github.com/kofijohnson
********************************************************************************************************/

public class MicroTriggerResult {
    public String MicroTriggerName {get; private set;}
    public List<String> SuccessActions {get; set;}
    public List<String> FailActions {get; set;}
    public Boolean IsActive {get; set;}
    public List<SObject> QualifiedRecords {get; set;}
    public Boolean CriteriaIsMet { get {
        return QualifiedRecords.isEmpty() == false;
    }}

    /*******************************************************************************************************
    * @description Constructor. Initializes trigger result object
    * @param microTriggerName The developer name for this MicroTrigger
    ********************************************************************************************************/
    public MicroTriggerResult(String microTriggerName) {
        IsActive = false;
        this.MicroTriggerName = microTriggerName;
        SuccessActions = new List<String>();
        FailActions = new List<String>();
        QualifiedRecords = new List<SObject>();
    }
}