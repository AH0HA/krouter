#cat kmem
#./krouter -s "event_a1_x1" -verbose
#./krouter -s "event_c3_z2" -verbose
./krouter -s "event_a1_x1" -a "./to_do"
./krouter -s "event_c3_z2"  -a "./to_do"
#cat kmem
