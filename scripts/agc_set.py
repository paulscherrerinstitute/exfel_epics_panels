import epics
import time
from multiprocessing import Process, Queue
import pexpect
from datetime import datetime

inj = (
("xfelgpac1di30i1",  "0xFE", "0xFE", "but" , "but"     ),
("xfelgpac1di55i1",  "0xFA", "0xFA", "but" , "ren"     ),
("xfelgpac2di55i1",  "0xFA", "0xFA", "cav" , "cav"     ),
("xfelgpac3di55i1",  "0xFA", "0xFA", "but" , "cav"     ),
("xfelgpac1di59i1",  "0xFA", "0xFA", "but" , "but"     ),
("xfelgpac1di94i1",  "0xEA", "0xEA", "but" , "but"     ),
("xfelgpac2di94i1",  "0xEA", "0xEA", "but" , "but"     ),
("xfelgpac3di94i1",  "0xEA", "0xEA", "but" , ""        ),
("xfelgpac4di94i1",  "0xEA", "0xEA", "cav" , "cav"     ),
("xfelgpac1di107i1", "0xEA", "0xEA", "but" , "but"     ),
("xfelgpac2di107i1", "0xEA", "0xEA", "but" , "but"     ),
("xfelgpac1di160l1", "0xEA", "0xEA", "but" , "ren"     ),
("xfelgpac2di160l1", "0xEA", "0xEA", ""    , "ren"    )
)

rest=(
    # ("xfelgpac1di176b1", "0xEA", "0xEA", "but", "cav"),
    # ("xfelgpac1di203b1", "0xEA", "0xEA", "but", "cav"),
    # ("xfelgpac1di215b1", "0xEA", "0xEA", "but", "but"),
    # ("xfelgpac1di220b1", "0xEA", "0xEA", "but", "but"),
    # ("xfelgpac1di240b1", "0xEA", "0xEA", "but", "but"),
    # ("xfelgpac1di276l2", "0xCA", "0xCA", "but", "ren"),
    # ("xfelgpac2di276l2", "0xCA", "0xCA", "", "ren"),
    # ("xfelgpac1di324l2", "0xCA", "0xCA", "but", "ren"),
    # ("xfelgpac2di324l2", "0xCA", "0xCA", "", "ren"),
    # ("xfelgpac1di372l2", "0xCA", "0xCA", "but", "ren"),
    # ("xfelgpac2di372l2", "0xCA", "0xCA", "", "ren"),
    # ("xfelgpac1di390b2", "0xCA", "0xCA", "but", "cav"),
    # ("xfelgpac1di415b2", "0xCA", "0xCA", "but", "cav"),
    # ("xfelgpac1di438b2", "0xCA", "0xCA", "but", "but"),
    # ("xfelgpac1di458b2", "0xCA", "0xCA", "but", "but"),
    # ("xfelgpac2di458b2", "0xCA", "0xCA", "but", "but"),
    # ("xfelgpac3di458b2", "0xCA", "0xCA", "but", "but"),
    # ("xfelgpac1di514l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di562l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac2di562l3", "0x8A", "0x8A", "", "ren"),
    # ("xfelgpac1di610l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac2di610l3", "0x8A", "0x8A", "", "ren"),
    # ("xfelgpac1di661l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di709l3", "0x8A", "0x8A", "but", "ren"),
    # ("xfelgpac2di709l3", "0x8A", "0x8A", "", "ren"),
    # ("xfelgpac1di757l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac2di757l3", "0x8A", "0x8A", "", "ren"),
    # ("xfelgpac1di808l3", "0x8A", "0x8A", "but", "ren"),
    # ("xfelgpac2di808l3", "0x8A", "0x8A", "", "ren"),
    # ("xfelgpac1di856l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di904l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di955l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di1003l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di1051l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di1102l3", "0x8A", "0x8A", "but", "ren"),
    # ("xfelgpac2di1102l3", "0x8A", "0x8A", "", "ren"),
    # ("xfelgpac1di1150l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di1198l3", "0x8A", "0x8A", "but", "ren"),
    # ("xfelgpac1di1249l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di1297l3", "0x8A", "0x8A", "but", "ren"),
    # ("xfelgpac1di1345l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di1396l3", "0x8A", "0x8A", "but", "ren"),
    # ("xfelgpac1di1444l3", "0x8A", "0x8A", "but", "ren"),
    # ("xfelgpac1di1499l3", "0x8A", "0x8A", "but", ""),
    # ("xfelgpac1di1601l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di1656l3", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac1di1685cl", "0x8A", "0x8A", "cav", "cav"),
    # ("xfelgpac1di1720cl", "0x8A", "0x8A", "but", "but"),
    # ("xfelgpac2di1720cl", "0x8A", "0x8A", "but", "cav"),
    ("xfelgpac1di1755cl", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac2di1755cl", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1793cl", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1828cl", "0x8A", "0x8A", "but", "cav"),
    ("xfelgpac1di1862tl", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1899tl", "0x8A", "0x8A", "cav", "cav"),
    ("xfelgpac2di1899tl", "0x8A", "0x8A", "cav", "cav"),
    ("xfelgpac3di1899tl", "0x8A", "0x8A", "cav", "cav"),
    ("xfelgpac4di1899tl", "0x8A", "0x8A", "cav", "cav"),
    ("xfelgpac1di1973tl", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di2018tl", "0x8", "0x2", "but", "but"),
    ("xfelgpac1di2100t2", "0x8", "0x8", "but", ""),
    ("xfelgpac1dixs1ug3r02t1", "0x8", "0x2", "but", "but"),
    ("xfelgpac1di2180t2", "0x8", "0x8", "but", "but"),
    ("xfelgpac1di2225t2", "0x8", "0x8", "but", ""),
    ("xfelgpac1di2232t2", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2244sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2256sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2268sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2280sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2293sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2305sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2317sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2329sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2341sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2354sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2366sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2378sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2390sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2402sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2415sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2427sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2439sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2451sa1", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2463sa1", "0x8", "0x8", "", "cav"),
    ("xfelgpac1di2480t4", "0x8", "0x8", "but", "but"),
    ("xfelgpac1di2548t4", "0x8", "0x8", "but", "but"),
    ("xfelgpac1di2590t4", "0x8", "0x8", "but", "but"),
    ("xfelgpac1di2623t4", "0x8", "0x8", "but", "but"),
    ("xfelgpac1di2686t4", "0x8", "0x8", "but", "but"),
    ("xfelgpac1dixs3ug2t4", "0x8", "0x8", "but", "but"),
    ("xfelgpac1di2793t4", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2808sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2820sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2832sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2845sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2857sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2869sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2881sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2893sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2906sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2918sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2931sa3", "0x8", "0x8", "cav", "cav"),
    ("xfelgpac1di2943sa3", "0x8", "0x8", "but", "cav"),
    ("xfelgpac1di3065t4d", "0x8", "0x8", "but", "cav"),
    ("xfelgpac2di3065t4d", "0x8", "0x8", "but", "but"),
    ("xfelgpac1di3090t4d", "0x8", "0x8", "but", ""),
    ("xfelgpac1di2047t1", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2074t1", "0x2", "0x2", "but", "but"),
    ("xfelgpac2di2100t1", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2175t1", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2194t1", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2207sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2219sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2231sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2244sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2256sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2268sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2280sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2286sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2292sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2305sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2317sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2329sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2341sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2353sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2366sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2378sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2390sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2402sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2414sa2", "0x2", "0x2", "cav", "cav"),
    ("xfelgpac1di2423sa2", "0x2", "0x2", "", "cav"),
    ("xfelgpac1di2444t3", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2500t3", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2550t3", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2585t3", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2632t3", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2723un1", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2785t5", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2820t5", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2848t5", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2911t5", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di2972t5", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di3055t5d", "0x2", "0x2", "but", "but"),
    ("xfelgpac1di3145t5d", "0x2", "0x2", "but", "cav"),
    ("xfelgpac1dixsdu1ug1t5d", "0x2", "0x2", "but", "but"),
    ("xfelgpac2dixsdu1ug1t5d", "0x2", "0x2", "but", ""),
    ("xfelgpac1di2018tld", "0x80", "0x80", "but", "but"),
    ("xfelgpac1di2047tld", "0x80", "0x80", "but", "but"),
    ("xfelgpac1di2074tld", "0x8", "0x80", "but", "but"),
    ("xfelgpac3di2100tld", "0x80", "0x80", "but", "but"),
    ("xfelgpac1dixs1ug3tld", "0x80", "0x80", "but", "")
)

def cavtype(nam):
    ret = "EMPTY "
    if nam == "but":
        ret = "BUTTON"
    elif nam == "cav":
        ret = "CAVITY"
    elif nam == "ren":
        ret = "REENTR"
    return ret

EEPROM_READY = 2
EEPROM_WRITING = 4

def set_button_bpm_dst_mask(host, bpmnum, dst_mask, queue, dbg = False):
    if dbg: print('set_button_bpm_dst_mask({}, {:d}, 0x{:04x})'.format(host, bpmnum, dst_mask))
    port_offset = 51245
    dest_addr =  host + ":" + str(port_offset+bpmnum)
    epics.caput("BUTBPMSERV:S7GPAC-ADDR", dest_addr)
    time.sleep(0.5)
    while epics.caget("BUTBPMSERV:S7GPAC-STATUS") != 1:
        time.sleep(0.5)

    while True:
        x = epics.caget("BUTBPMSERV:BPM-EEPROM-STATUS")
        if x == EEPROM_READY:
            break
        else:
            if dbg: print("EEPROM not ready" + " x=" + str(x))
            time.sleep(1.0)
                
    epics.caput("BUTBPMSERV:X2TIM-DEST-BUNCH-MASK", dst_mask)
    epics.caput("BUTBPMSERV:BPM-EEPROM-CMD", 2)
    time.sleep(0.5)
    epics.caput("BUTBPMSERV:BPM-EEPROM-CMD", 0)
    time.sleep(2)
    while True:
        x = epics.caget("BUTBPMSERV:BPM-EEPROM-STATUS")
        if x == EEPROM_READY:
            break
        if x == EEPROM_WRITING:
            if dbg: print("EEPROM writing" + " x=" + str(x))
        else:
            if dbg: print("EEPROM not ready" + " x=" + str(x))
        time.sleep(1.0)

    queue.put(0) # no error

def set_cavity_bpm_dst_mask(host, bpmnum, dst_mask, queue, dbg = False):
    if dbg: print('set_cavity_bpm_dst_mask({}, {:d}, 0x{:04x})'.format(host, bpmnum, dst_mask))
    child = pexpect.spawn('telnet ' + host)
    child.expect('login:')
    child.sendline('root')
    child.expect('Password:')
    child.sendline('gpac4ever')
    child.expect('#')
    if dbg: print('login OK')
    child.sendline('/mnt/cf/usr/bin/setbpmdm.sh {:d} 0x{:08x}'.format(bpmnum, dst_mask))
    child.expect('changed to ')
    child.expect('\r')
    if dbg: print('script OK, mask changed to: {}'.format(str(child.before)))

    queue.put(0) # no error
     
now = datetime.now()
nowstr = now.strftime('%Y_%m_%d_%H%M')

f_success = open("agc_set_{}.log".format(nowstr), "w+")
f_failed = open("agc_set_{}.err".format(nowstr), "w+")

# host = 'xfelgpac1di30i1'
# mask = 0xFE
# num = 0


# for num in range(0,4):
#     p = Process(target=set_button_bpm_dst_mask, args=(host, num, mask))
#     print('Running {} BPM: {:d}'.format(host, num))
#     p.start()
#     p.join(60)
#     if p.is_alive():
#         p.terminate()
#         p.join()
#         f_failed.write('{} Slot:{:d} 0x{:08x}\n'.format(host, num, mask))
#         print('Timeout')
#     else:
#         f_success.write('{} Slot:{:d} 0x{:08x}\n'.format(host, num, mask))
#         print('Done')

# host = 'xfelgpac1di30i1'
# mask = 0xFE
# num = 0

# host = 'xfelgpac1di55i1'
# mask = 0xFA
# num = 1

# p = Process(target=set_cavity_bpm_dst_mask, args=(host, num, mask, True))
# print('Running {} BPM: {:d}'.format(host, num))
# p.start()
# p.join(60)
# if p.is_alive():
#     p.terminate()
#     p.join()
#     f_failed.write('{} Slot:{:d} 0x{:08x}\n'.format(host, num, mask))
#     print('Timeout')
# else:
#     f_success.write('{} Slot:{:d} 0x{:08x}\n'.format(host, num, mask))
#     print('Done')


def set_mbu_dst_mask(bpm_entry, f_success=False, f_failed=False, dbg=False):
    queue = Queue()
    host = bpm_entry[0]
    processes = list()
    slots = list()
    types = list()
    for i in range(0,2):
        mask = int(bpm_entry[1+i],16)
        bpm_type = bpm_entry[3+i]
        if bpm_type == "but":
            processes.extend([Process(target=set_button_bpm_dst_mask,
                                      args=(host, num, mask, queue, dbg))
                              for num in [2*i, 2*i+1]])
            slots.extend([num for num in [2*i, 2*i+1]])
            types.extend([bpm_type for num in [2*i, 2*i+1]])
        elif bpm_type == "cav" or bpm_type == "ren" :
            processes.extend([Process(target=set_cavity_bpm_dst_mask,
                                      args=(host, i+1, mask, queue, dbg))])
            slots.extend([2*i])
            types.extend([bpm_type])

    print('{}'.format(slots))
    print('{}'.format(types))
    for (p,slot,typ) in zip(processes,slots,types):
        print('Running {} BPM: {} Type: {}'.format(host, slot+1, typ))
        p.start()
        try:
            timeouted=False
            proc_ret=queue.get(timeout=60)
        except:
            timeouted=True
            
        if p.is_alive():
            p.terminate()
            p.join()

        if timeouted:
            if f_failed: f_failed.write('{} Slot:{:d} Type:{} 0x{:08x}\n'.format(host, slot+1, typ, mask))
            print('Timeout')
        elif proc_ret == 0:
            if f_success: f_success.write('{} Slot:{:d} Type:{} 0x{:08x}\n'.format(host, slot+1, typ, mask))
            print('Done')
        else:
            if f_failed: f_failed.write('{} Slot:{:d} Type:{} 0x{:08x}\n'.format(host, slot+1, typ, mask))
            print('Error: {:d}'.format(proc_ret))

for bpm in rest:
    set_mbu_dst_mask(bpm, f_success, f_failed, True)          
     
    
