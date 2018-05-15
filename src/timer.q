/////////////
// PRIVATE //
/////////////

.timer.priv.timers:1!flip`tag`nextrun`interval`func`args!"spn**"$\:()

///
// Periodic timer
// @param timestamp timestamp Current time
.timer.priv.ts:{[timestamp]
  if[count data:select tag,nextrun:timestamp+interval from .timer.priv.timers where nextrun<timestamp;
    upsert[`.timer.priv.timers;data];
    .timer.priv.call'[data`tag];
    delete from`.timer.priv.timers where null nextrun];
  }

///
// Sets a timer with a given tag to execute a function periodically
// @param tag symbol Tag to identify timer
// @param nextrun timestamp Next time to execute function
// @param interval timespan Interval to execute function
// @param func function Function to execute
// @param args any Arguments to pass to func
.timer.priv.set:{[tag;nextrun;interval;func;args]
  upsert[`.timer.priv.timers;(tag;nextrun;interval;enlist func;enlist args)];
  }

///
// Calls the specified timer function
// @param tag symbol Tag to uniquely identify timer
.timer.priv.call:{[tag]
  $[1=count last timer;@;.]. timer:first@'.timer.priv.timers[tag;`func`args]
  }

////////////
// PUBLIC //
////////////

///
// Sets a one-shot timer to be executed in a specified time
// @param tag symbol Tag to identify timer
// @param time timespan Time until function will be executed
// @param func function Function to execute
// @param args any Arguments to pass to func
.timer.in:{[tag;time;func;args]
  .timer.priv.set[tag;.z.p+time;0Nn;func;args];
  }

///
// Sets a one-shot timer to be executed at a specified time
// @param tag symbol Tag to identify timer
// @param time timestamp Time at which function will be executed
// @param func function Function to execute
// @param args any Arguments to pass to func
.timer.at:{[tag;time;func;args]
  .timer.priv.set[tag;time;0Nn;func;args];
  }

///
// Sets a repeating timer to be executed periodically at a specified interval
// @param tag symbol Tag to identify timer
// @param time timespan Time until function will be executed
// @param func function Function to execute
// @param args any Arguments to pass to func
.timer.every:{[tag;time;func;args]
  .timer.priv.set[tag;.z.p+time;time;func;args];
  }

///
// Sets a repeating timer to be executed periodically at a specified time
// @param tag symbol Tag to identify timer
// @param time timespan Time at which function will be executed
// @param func function Function to execute
// @param args any Arguments to pass to func
.timer.atEvery:{[tag;time;func;args]
  // TODO: check if .z.d/.z.d+1
  .timer.priv.set[tag;.z.d+time;1D;func;args];
  }

//////////
// INIT //
//////////

.dotz.append[`.z.ts;.timer.priv.ts]
if[not system"t";system"t 1000"]
