
start run_ws.bat

ping -n 3 127.0.0.1>nul

start run_gc.bat

ping -n 3 127.0.0.1>nul

start run_gs.bat

ping -n 3 127.0.0.1>nul

start run_gs2.bat

ping -n 3 127.0.0.1>nul

start run_sdk_gate.bat

echo ping -n 3 127.0.0.1>nul

start run_sdk_billing.bat

ping -n 3 127.0.0.1>nul

start run_ls.bat

