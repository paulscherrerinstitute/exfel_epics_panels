#!/usr/bin/python3

import argparse
import collections
import epics
import time
from multiprocessing import Process, Queue
import pexpect
from datetime import datetime


#mbu name, bpm0_mask, bpm1_mask, bpm0_type, bpm1_type
mbu_list = (
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
    ("xfelgpac2di160l1", "0xEA", "0xEA", ""    , "ren"    ),
    ("xfelgpac1di176b1", "0xEA", "0xEA", "but", "cav"),
    ("xfelgpac1di203b1", "0xEA", "0xEA", "but", "cav"),
    ("xfelgpac1di215b1", "0xEA", "0xEA", "but", "but"),
    ("xfelgpac1di220b1", "0xEA", "0xEA", "but", "but"),
    ("xfelgpac1di240b1", "0xEA", "0xEA", "but", "but"),
    ("xfelgpac1di276l2", "0xCA", "0xCA", "but", "ren"),
    ("xfelgpac2di276l2", "0xCA", "0xCA", "", "ren"),
    ("xfelgpac1di324l2", "0xCA", "0xCA", "but", "ren"),
    ("xfelgpac2di324l2", "0xCA", "0xCA", "", "ren"),
    ("xfelgpac1di372l2", "0xCA", "0xCA", "but", "ren"),
    ("xfelgpac2di372l2", "0xCA", "0xCA", "", "ren"),
    ("xfelgpac1di390b2", "0xCA", "0xCA", "but", "cav"),
    ("xfelgpac1di415b2", "0xCA", "0xCA", "but", "cav"),
    ("xfelgpac1di438b2", "0xCA", "0xCA", "but", "but"),
    ("xfelgpac1di458b2", "0xCA", "0xCA", "but", "but"),
    ("xfelgpac2di458b2", "0xCA", "0xCA", "but", "but"),
    ("xfelgpac3di458b2", "0xCA", "0xCA", "but", "but"),
    ("xfelgpac1di514l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di562l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac2di562l3", "0x8A", "0x8A", "", "ren"),
    ("xfelgpac1di610l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac2di610l3", "0x8A", "0x8A", "", "ren"),
    ("xfelgpac1di661l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di709l3", "0x8A", "0x8A", "but", "ren"),
    ("xfelgpac2di709l3", "0x8A", "0x8A", "", "ren"),
    ("xfelgpac1di757l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac2di757l3", "0x8A", "0x8A", "", "ren"),
    ("xfelgpac1di808l3", "0x8A", "0x8A", "but", "ren"),
    ("xfelgpac2di808l3", "0x8A", "0x8A", "", "ren"),
    ("xfelgpac1di856l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di904l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di955l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1003l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1051l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1102l3", "0x8A", "0x8A", "but", "ren"),
    ("xfelgpac2di1102l3", "0x8A", "0x8A", "", "ren"),
    ("xfelgpac1di1150l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1198l3", "0x8A", "0x8A", "but", "ren"),
    ("xfelgpac1di1249l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1297l3", "0x8A", "0x8A", "but", "ren"),
    ("xfelgpac1di1345l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1396l3", "0x8A", "0x8A", "but", "ren"),
    ("xfelgpac1di1444l3", "0x8A", "0x8A", "but", "ren"),
    ("xfelgpac1di1499l3", "0x8A", "0x8A", "but", ""),
    ("xfelgpac1di1601l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1656l3", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac1di1685cl", "0x8A", "0x8A", "cav", "cav"),
    ("xfelgpac1di1720cl", "0x8A", "0x8A", "but", "but"),
    ("xfelgpac2di1720cl", "0x8A", "0x8A", "but", "cav"),
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

class bpmProcess:
    def __init__(self,target, host, bpm_type, queue, slot, dest_mask, debug):
        self.proc = Process(target=target, args=(host, bpm_type, slot, dest_mask, queue, debug))
        self.host = host
        self.bpm_type = bpm_type
        self.slot = slot
        self.mask = dest_mask
        self.queue = queue
        self.debug = debug

class bpmProcessRet:
    def __init__(self,return_value, error = False, error_string = "No error"):
        self.error = error
        self.return_value = return_value
        self.error_string = error_string

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

def set_button_bpm_dst_mask(host, bpm_type, bpmnum, port_offset, dst_mask, dbg = False):
    if dbg: print('set_button_bpm_dst_mask({}, {}, {}, {}, 0x{:04x})'.format(host, bpm_type, bpmnum, port_offset,  dst_mask))
    #port_offset = 51245
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
    time.sleep(2)
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
    return  bpmProcessRet(0)


def set_cavity_bpm_dst_mask(host, bpm_type, bpmnum, port_offset, dst_mask, dbg = False):
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
    return bpmProcessRet(0)

def set_bpm_dst_mask(host, bpm_type, bpmnum, dst_mask, queue, dbg = False):
    retval = bpmSetFuncDict[bpm_type](host, bpm_type, bpmnum, bpmServerPortOffsetDict[bpm_type], dst_mask, dbg)
    queue.put(retval) # no error

def get_universal_bpm_dst_mask(host, bpm_type, bpmnum, port_offset, dst_mask, dbg = False):
    if dbg: print('get_universal_dst_mask({}, {}, {:d}'.format(host, bpm_type, bpmnum))
    #port_offset = 51245
    server_name = bpmServerNamesDict[bpm_type]
    dest_addr =  host + ":" + str(port_offset+bpmnum)
    epics.caput(server_name + ":S7GPAC-ADDR", dest_addr)
    time.sleep(0.5)
    while epics.caget(server_name + ":S7GPAC-STATUS") != 1:
        time.sleep(0.5)

    time.sleep(1)
    print("GOT: " + epics.caget(server_name + ":X2TIM-DEST-BUNCH-MASK.VAL",as_string=True))
    time.sleep(0.5)
    ret = epics.caget(server_name + ":X2TIM-DEST-BUNCH-MASK.VAL")
    epics.caput(server_name + ":S7GPAC-ADDR", ":" + str(port_offset+bpmnum))
    return bpmProcessRet(ret)

def get_direct_bpm_dst_mask(host, bpm_type, bpmnum, dst_mask, queue, dbg = False ):
    if dbg: print('get_direct_dst_mask({}, {}, {:d})'.format(host, bpm_type, bpmnum))
    addr = bpmMrdOffsets[bpm_type][bpmnum];
    if dbg: print('read from addr: 0x{:08x}'.format(addr))
    child = pexpect.spawn('telnet ' + host)
    child.expect('login:')
    child.sendline('root')
    child.expect('Password:')
    child.sendline('gpac4ever')
    child.expect('#')
    if dbg: print('login OK')
    child.sendline('mrd 0x{:08x},1,1'.format(addr))
    child.expect(':\s+')
    child.expect('\r')
    try:
        retval = int(child.before,16)
    except:
        if dbg: print('returned value not hex, got: {}'.format(str(child.before)))
        return bpmProcessRet(0, error=True, error_string='returned value not hex, got: {}'.format(str(child.before)))
    else:
        if dbg: print('success, mask is: 0x{:08x}'.format(retval))
        return bpmProcessRet(retval)



def read_bpm_dst_mask(host, bpm_type, bpmnum, dst_mask, queue, dbg = False):
    if dbg: print('read_bpm_dst_mask(host={}, bpm_type={}, bpmnum={}, dst_mask={}'.format(host, bpm_type, bpmnum, dst_mask))
    retval = bpmGetFuncDict[bpm_type](host, bpm_type, bpmnum, bpmServerPortOffsetDict[bpm_type], dst_mask, dbg)
    queue.put(retval)
                  
def verify_bpm_dst_mask(host, bpm_type, bpmnum, dst_mask, queue, dbg = False):
    retval = bpmGetFuncDict[bpm_type](host, bpm_type, bpmnum, bpmServerPortOffsetDict[bpm_type], dst_mask, dbg)
    if retval.error:
        queue.put(retval)
    elif retval.return_value == dst_mask:
        queue.put(retval)
    else:
        queue.put(bpmProcessRet(retval.return_value, error = True, error_string = 'Expected 0x{:08x} got 0x{:08x}'.format(dst_mask, retval.return_value)))
        

bpmServerNamesDict = {'but' : 'BUTBPMSERV', 'cav' : 'CAVBPM', 'ren' : 'RENBPM'}
bpmServerPortOffsetDict = {'but' : 51245, 'cav' : 51235, 'ren' : 51235}
bpmProcDict = {'set': set_bpm_dst_mask, 'read' : read_bpm_dst_mask, 'verify' : verify_bpm_dst_mask}
bpmSetFuncDict = {'but': set_button_bpm_dst_mask, 'cav' : set_cavity_bpm_dst_mask, 'ren' : set_cavity_bpm_dst_mask}
bpmGetFuncDict = {'but': get_universal_bpm_dst_mask, 'cav' : get_universal_bpm_dst_mask, 'ren' : get_universal_bpm_dst_mask}

### Ofsets taken from .sub and .rd gpacsrv configuration files
# BPMSERV
# BUT_EEPROM      0x00000048		  1	 # 0x0084 - X2TIM-DEST-BUNCH-MASK
# BPM1
# 0x80A04000  BUT_EEPROM        # 0x08004000 in BPM FPGA
# BPM2
# 0x80A06000  BUT_EEPROM        # 0x08006000 in BPM FPGA
# BPM3
# 0x81204000  BUT_EEPROM        # 0x08004000 in BPM FPGA
# BPM4
# 0x81206000  BUT_EEPROM        # 0x08004000 in BPM FPGA
# CAVBPM
# SYS_INIT        0x00000500          1    # 0x0294 - X2TIM-DEST-BUNCH-MASK
# BPM1
# 0x80838000      SYS_INIT
# BPM2
# 0x81038000      SYS_INIT
# REENCAV
# SYS_INIT        0x00000500          1    # 0x0218 - X2TIM-DEST-BUNCH-MASK
# BPM1
# 0x80838000    SYS_INIT
# BPM2
# 0x81038000    SYS_INIT
###

bpmMrdOffsets = {'but' : (0x80A04000 + 0x48, 0x80A06000 + 0x48, 0x81204000 + 0x48, 0x81206000 + 0x48),
                 'cav' : (0x80838000 + 0x500, 0x80838000 + 0x500, 0x81038000 + 0x500, 0x81038000 + 0x500),
                 'ren' : (0x80838000 + 0x500, 0x80838000 + 0x500, 0x81038000 + 0x500, 0x81038000 + 0x500)}

def make_proc_mbu_dst_mask(proc_type, bpm_entry, queue, slot, dbg):
#    if dbg: print('make_proc_mbu_dst_mask(proc_type={}, bpm_entry={}, slot={}'.format(proc_type, bpm_entry, slot))
#    if dbg: print('bpmProcDict[proc_type]=={}'.format(bpmProcDict[proc_type]))
    host = bpm_entry[0]
    dest_mask = int(bpm_entry[1+slot//2],16)
    bpm_type = bpm_entry[3+slot//2]
    retproc = None
    if bpm_type == '':
        return retproc
    elif bpm_type == "but":
        retproc = bpmProcess(bpmProcDict[proc_type],host,bpm_type,queue,slot,dest_mask,dbg)
    else:
        if slot == 0 or slot == 2:
            retproc = bpmProcess(bpmProcDict[proc_type],host,bpm_type,queue,slot+1,dest_mask,dbg)
    return retproc

def execute_processes(bpm_process_l, f_success=False, f_failed=False, dbg=False):
    for proc in bpm_process_l:
        if proc:
            print('Running {} BPM: {} Type: {}'.format(proc.host, proc.slot+1, proc.bpm_type))
            proc.proc.start()
            try:
                timeouted=False
                proc_ret=proc.queue.get(timeout=60)
            except:
                timeouted=True

            if proc.proc.is_alive():
                proc.proc.terminate()
                proc.proc.join()

            proc.queue.close()

            if timeouted:
                if f_failed: f_failed.write('{} Slot:{:d} Type:{} 0x{:08x} Timeout\n'.format(proc.host, proc.slot+1, proc.bpm_type, proc.mask))
                print('Timeout')
            elif not proc_ret.error:
                if f_success: f_success.write('{} Slot:{:d} Type:{} 0x{:08x}\n'.format(proc.host, proc.slot+1, proc.bpm_type, proc_ret.return_value))
                print('Done, returned: 0x{:08x}'.format(proc_ret.return_value))
            else:
                if f_failed: f_failed.write('{} Slot:{:d} Type:{} Error: {}\n'.format(proc.host, proc.slot+1, proc.bpm_type, proc_ret.error_string))
                print('Error: {}'.format(proc_ret.error_string))

def main():
    parser = argparse.ArgumentParser(description='Set/Read/Verify AGC location mask')
    group = parser.add_mutually_exclusive_group()
    parser.add_argument('action', choices=['set', 'read', 'verify'], help='action to be performed')
    group.add_argument('-a', '--all', help='perform action on all known MBUs', action='store_true')
    parser.add_argument('-d', '--direct', help='use direct readback using mrd and not EPICS', action='store_true')
    group.add_argument('-f', '--file', help='load MBU list from first column of a file', type=argparse.FileType('r'))
    parser.add_argument('mbu', nargs='*', help='list of MBUs to perform action on, optionally use --all')
    parser.add_argument('-v', '--verbose', help='show debug messages', action='store_true')
    args = parser.parse_args()

    if args.verbose:
        print('Verbose mode on')
        print('Selected action is: ' + args.action)
    
    # names of all known MBUs
    mbu_names = [m[0] for m in mbu_list]

    
    if args.direct:
        for key in bpmGetFuncDict.keys():
            bpmGetFuncDict[key] = get_direct_bpm_dst_mask

    if args.all:
        print('Using ALL MBUs')
        selected_mbus = mbu_names
    elif args.file:
        print('Using file {}'.format(args.file.name))
        selected_mbus = [line.split()[0] for line in args.file]
        #remove duplicates
        #selected_mbus = list(set(selected_mbus))
        #this removes duplicates and preserves order, but is O(n^2)
        selected_mbus=[ii for n,ii in enumerate(selected_mbus) if ii not in selected_mbus[:n]]
    else:
        selected_mbus = args.mbu
              
    unknown = [x for x in selected_mbus if x not in mbu_names]
    if unknown:
        print('Unknown MBUs selected: ' + ', '.join(unknown))
        return -1

    if args.verbose:
        print('List of MBUs: \n' + '\n'.join(selected_mbus))

    now = datetime.now()
    nowstr = now.strftime('%Y_%m_%d_%H%M')
    f_success_name = "agc_set_{}.log".format(nowstr)
    f_failed_name = "agc_set_{}.err".format(nowstr)
    
    f_success = open(f_success_name, "w+")
    print('Opened log file: ' + f_success_name)

    f_failed = open(f_failed_name, "w+")
    print('Opened error file: ' + f_failed_name)

    process_list = []

    
    for mbu in selected_mbus:
        mbu_entry = next((x for x in mbu_list if x[0] == mbu))
        for slot in range(0,4):
            queue = Queue()
            process_list.append(make_proc_mbu_dst_mask(args.action, mbu_entry, queue, slot, args.verbose))

    execute_processes(process_list, f_success, f_failed, args.verbose)


if __name__ == "__main__":
    main()
