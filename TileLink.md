/* 

    Author : Badr Mesbahi

*/


# TileLink
TileLink is an interconnect standard design to connect multiple masters with coherent memory-mapped access to memory and other slave devices. 

TileLink is designed for use in a Systemon-Chip (SoC) to connect general-purpose multiprocessors, co-processors, accelerators, DMA engines, and simple or complex devices.

## Types :

TL-UL : TileLink uncached lightweight 

TL-UH : Tilelink uncached heavyweight

TL-C  : Tilelink cached

N.B : the communication between TL-C and TL-UL must use a TL-C-to-TL-UL adapter.

## Network Topology :

The topology needed to avoid deadlock is any Topology that can be described as Direct Acyclic Graph (DAG), this is a necessary property for TileLink to remain deadlock free.

every agent master has a master interface, and every slave has a slace interface (an agent can have both if it needs to perform slave and master operations).

qst : if an module had both interfaces (Master & slave), it is considered as two agents or only one ?

Answer : if the upcomming messages on the slave interface makes the master interface send something is this case is considered as one agent, otherwise two.

## Channels :

The two basic channels required to perform memory access operations are:


<span style="color:#1AD8FF">Channel A</span> : Transmits a request that an operation be performed on a specified address range, accessing or caching the data.

<span style="color:#1AD8FF">Channel D</span> : Transmits a data response or acknowledgement message to the original requestor.

The highest protocol conformance level (TL-C) adds three additional channels that provide the
capability to manage permissions on cached blocks of data:

<span style="color:#1AD8FF">Channel B</span> : Transmits a request that an operation be performed at an address cached by a master agent, accessing or writing back that cached data.

<span style="color:#1AD8FF">Channel C</span> : Transmits a data or acknowledgment message in response to a Channel B request.

<span style="color:#1AD8FF">Channel E</span> : Transmits a final acknowledgment (handshake) of a cache block transfer from the original requestor, used for serialization. 

## Signals

channel A :

a_opcode [type c , width 3] ->  Operation code 
a_param  [type c , width 3] ->  Parameter code


## Serialization :

burst : is a multi-beat message (needs many clock cycles or beats).

N.B:  It is forbidden in TileLink to interleave the beats of different messages on a channel.

## Flow control rules :

In order to implement correct ready-valid handshaking, these rules must be followed:

• If ready is LOW, the receiver must not process the beat and the sender must not consider
the beat processed.

• If valid is LOW, the receiver must not expect the control or data signals to be a syntactically
correct TileLink beat.

• Valid must never depend on ready. If a sender wishes to send a beat, it must assert valid
independently of whether the receiver signals that it is ready.

• As a consequence, there must be no combinational path from ready to valid or any of the
control and data signals.

• A receiver may only hold ready LOW in accordance with the deadlock freedom rules.

in-progress message : 

## Deadlock freedom

there is two conditions to respect in order to avoid deadlock problem:

- Define rules that govern the conditions under which a receiving agent may reject a beat of 
a message.

- The structure of agents and links must be a DAG.

By combining these two rulesets with the strict prioritization of channels within the network,
we can provably guarantee that correct TileLink implementations will not deadlock.

this words are used to descibe the rules :

request message: a message specifying an operation to perform (access or transfer).

follow-up message: a message sent as a result of receiving some other message.

response message: a mandatory follow-up message paired to a request.

recursive message: any follow-up message nested inside a request/response pair.

forwarded message: a recursive message that is at the same level of priority as the message
that initiated it.

### Forward Progress Rules for Agents
In TileLink, there are only four legitimate reasons a conforming agent may reject a valid beat by lowering ready:


1- A receiver may choose to enter a bounded busy period, during which it never raises ready.

2- While a response to a request message received on channel X is being rejected, the responding agent may lower ready on all channels with priority ≤ X indefinitely.

3- 

4- 
[to be re-read , too complicated now]

### Topology Rules for Networks

The topology must be DAG. 

## Request-Response Message Ordering
The rules governing when response messages can be sent can be presented as following :

the response message may be presented on the response channel:

• on the same cycle that the first beat of the request message is presented, but not before.

• before all the beats of a burst request message have been accepted.

• after an arbitrarily long delay.

The following subsections elaborate on the interaction of request and response messages of different burst sizes.

### Burst Responses

- The response message can arrives after an arbitrary delay. The master interface must be willing to wait indefinitely for this response message, as timeouts within the TileLink network are forbidden.

Eventually, the response message arrives, which is guaranteed by TileLink’s deadlock freedom.

- The response message can arrives within the same cycle as the request message itself is accepted.

This overlap is allowed as soon as the first beat of the message is accepted.

figure : 4.3

### Burst Requests

### Burst Requests & Responses

## Errors

There is two type of errors :

- Corrupt data errors. 

- Access denied errors.