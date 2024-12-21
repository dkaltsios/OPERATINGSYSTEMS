public abstract class ShortTermScheduler{
  SDLRTYPE type;
  
  public abstract UserProcess selectUserProcess();
}
////////////////////////////////////////////////////////////////////
public abstract class MemoryManagerAlgorithm{
  MMANAGERTYPE type;
  
  public abstract Partition selectPartition();
}
////////////////////////////////////////////////////////////////////
public class DefaultScheduler extends ShortTermScheduler{
  
  DefaultScheduler() {
    super();
    type = SDLRTYPE.PREEMPTIVE;
  }
  
  public UserProcess selectUserProcess() {
    UserProcess result = null;
    if (myOS.suspended != null) {
      sim.addToLog("  >Scheduler: suspended process found (" + myOS.suspended.pid + ") in the ready queue");
      result = myOS.suspended;
      myOS.suspended = null;
    } else if (!myOS.readyQueue.isEmpty()) {
      result = myOS.readyQueue.get(0); 
    }
    return result;
  }
  
}

//////////////////////////////////////////////////////////////
public class DefaultMM extends MemoryManagerAlgorithm{
  
  DefaultMM() {
    super();
    type = MMANAGERTYPE.FIXED;
  }
  
  public Partition selectPartition() {
    Partition result = null;
    for (int i = 1; i < myOS.partitionTable.size(); i++) {
      if (myOS.partitionTable.get(i).isFree && myOS.partitionTable.get(i).size >= myOS.newProcessImage.length()) {
        result = myOS.partitionTable.get(i);
        result.isFree = false;
        break;
      }
    }
    if (result != null) {
      sim.addToLog("  >Memory Manager: Partition with BA: " + result.baseAddress + " was found. Starting Process Creator");
      myOS.raiseIRQ("createProcess");
    } else {
      sim.addToLog("  >Memory Manager: No partition was found. Starting Process Scheduler");
      sim.requestFails++;
      myOS.raiseIRQ("scheduler");
    }
    return result;
  }
  
}
