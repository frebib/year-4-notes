# Secure System Management

## Acronyms
- IA - _Information Assurance_
- IS - _Infosec Standard_

## Introduction (26/09/2017)

### Content
- Asset registers
  - What are we securing and why?
- Risk and threat analysis and modelling
  - What are we securing against?
  - Who are the attackers?
  - How motivated/prepared are they?
- Change management
  - Dealing with new assets and threats
  - Maintain existing security mechanisms and current systems
- Metrics and audit
  - How do we know how well we are doing?
  - Is 'it' being done at all?

### Methodologies
- ISO 27001 - information security management systems
- ISO 27005 - risk modelling
- HMG Information Security Standard 1 (UK gov certified programme)
- ISO 22301/22313 - business continuity

## CIA (28/09/2017)
- Confidentiality
  - Can data only be read by authorised?
- Integrity
  - Can data only be changed by authorised?
- Availability
  - Is data always available to authorised?

### Conventional Ratings
- Rated on 5, sometimes 6 point scale of "impact"
- 1 = "no or weak impact"
- 5 can = "major loss of life or vast economic harm
- Scales are decided for domain

### CIA Triples
- 334 is UK "RESTRICTED"
- 444 is UK "CONFIDENTIAL"
- 554 is UK "SECRET"
- 664 is UK "TOP SECRET"

#### IL 3
- "Risk to an individual’s personal safety or liberty"
- "Loss to HMG/Public Sector of £millions"
- "Undermine the financial viability of a minor UK based or UK-owned
  organisation"

#### IL 6
- "Lead directly to widespread loss of life"
- "Major, long term damage to the UK economy (to an estimated total in excess
  of £10 billion)"
- "Major, long term damage to global trade or commerce, leading to prolonged
  recession or hyperinflation in the UK"

### Cycle of Quality Systems (03/10/2017)
- Plan
  - Identify assets, risks, threats
  - Associate controls
- Do
  - Run the system with new controls
- Check
  - Design and collect metrics
  - Design and collect audit info
  - Assess the security of the system
- Act
  - Improve the system
  - Return to "do" or "plan"
  - Repeat


- ISO 9001

## Manufacturing
- **Policies:** state objectives and criteria of system
- **Procedures:** state how to do things, check to ensure fulfilment of
  policy objectives
  - Sometimes **Work Instructions** or **Method Statements:** done in
    more detail
- **Quality Records audited:** compliance checked with policies and procedures

### Compliance
- Internal auditors procedures are being followed
- External auditors check:
  - Policies are adequate
  - Procedures support policies
  - Procedures are followed
  - Helped by quality records and internal audit
- External auditors give certificate deeming quality system fit for purpose

### Governance
- Documents approved by named people who are accountable
- Document review dates
- Document issue/version control
- A way to get "latest" copy, protection against old copies
- Documents flow from requirements

### Document hierarchies
- 27001 offers guidance, other standards may be considered

### Policies
- How things should be, not how to do them
- Set objectives and high-level operational requirements
- Written by senior managers, approved by other senior managers or board-level
  directors
- Short in length, long in duration


- Clear and unambiguous
- Short as possible
- Cover majority of cases, process for dealing with exceptions
- No lengthy background material


**Examples**
- Why are we securing things, and who from?
- Do we prefer cloud or on-premises solutions?
- What legislation do we need to comply with?
- Who approves changes to our security system?

### Procedures
- How to do something correctly
- Can be checked against policies to confirm they implement requirements and
  objectives (should state which policies they are derived from)
- Generate quality records
- Written by operational managers
- Approved by their line managers


- Step-by-step descriptions of what needs to be done
- Always accurate and up-to-date
- Immediately flagged for review if not working
- Minimise opportunity for people to make inconsistent decisions


**Examples**
- How to deal with new staff
- How to manage departure of staff
- Who can be let into the building at night
- How to provision a new laptop

## Asset Registers (05/10/2017)
- Register of all info assets in the business
- Define scope of an information management system
- Should include everything that can affect security of information

### The full scope
- Everything you might want to record a **threat** against
  - Things an attacker may want to control/destroy/compromise
  - Things that might stop working
- Everything you might want to apply a **control** to
  - Things to consider

### Construction: an approach
1. Systems and databases
    * Payroll, HR, source control
2. Expand downwards
3. "What you can see"
    * Boxes ("tin"), buildings, people, cabling
4. Expand upwards


- Iterate and improve

#### Reality
- End up finding a lot of things you didn't know about
- Legacy systems and infrastructure

#### Maintenance
- Hard to add new systems and new dependencies
- Requires active co-operation
- Keeping up-to-date important to present current systems in use
  - This often doesn't get done because...who can be bothered?

## Risks and threats (10/10/2017)
### Threats, compromise methods, risks
- **Threats:** people who might do things
- **Compromise methods:** how they might do things
- **Risk:** consequence to defender of threat's success

#### Threats
- Something that an attacker might attempt to do to an asset
- To assess, look at attacker capability and intent
  - Attackers need both to be a danger


**HMG #1**
- **Threat source:** a person/organisation that desires to breach security and
  benefit
- **Threat actor:** a person that performs an attack
- **Threat level:** a level attributed to the to capability/motivation of a
  threat actor/source to an asset


**Deterrable?**
- Threat to lose job, clearance, livelihood, liberty...
- Appeal to "better nature", ethical codes, etc.

#### Compromise methods
- How an attack may be carried out
- Only considers methods plausible for identified threat sources

#### Risks
- Risks are things that might happen to an asset, combining likelihood with
  impact
- Risks for ISO 27001 include fire and flood that don't have threat actors


#### Risk assessment
- A list of things that might happen to assets, looking at likelihood and impact
- Multiplication is OK, breaks down for high impact/low likelihood events
  - Sometimes need to consider high impact events even if low likelihood
- Weigh outcomes in light of likelihood

#### Threat assessment
- A list of people that may attack you, looking at capability and motives
- Nation states have capability but for most people, limited intent
- Random fired dude likely has lots of intent, limited capability

### Threat Actors (according to HMG #1) (12/10/2017)
FoI = focus of interest

#### Bystander (BY)
- Authorised physical access to equipment
  - No business to handle or logically access
- e.g. Cleaners, visitors

#### Handler (HAN)
- Business role requires physical access to equipment
- No logical access to system
  - May have temporary supervised access for test purposes
- e.g. people that transport, test, repair or replace hardware

#### Indirectly Connected (IC)
- No legitimate or authorised business connectivity to the FoI
- May be able to access via business partners etc.
- e.g. Internet users where FoI has internet connectivity

#### Information Exchange Partner (IEP)
- Needs to exchange data with FoI through a media exchange
- May be originator, recipient or both
- e.g. Someone using a third-party email host

#### Person Within Range (PWR)
- Within range of electronic, electromagnetic, etc. emanations from equipment
- May be in a position to jam communication paths
- Can potentially steal data with specialist equipment
  - e.g. reading CRT screens without line-of-sight

#### Normal User (NU)
- Registered user or account holder that uses applications within FoI
  - Data can be stolen and leaked
  - Data can be deleted and modified
- Provided standard facilities and privileges

#### Physical Intruder (PI)
- Gains unauthorised physical access to equipment
  - e.g. someone breaking into a data centre
- By gaining access they have already broken the law so are more likely to
  cause damage or being more brutal and leaving traces

#### Privileged User (PU)
- Registered user/account holder that manages applications etc. within the FoI
- Usually can't be constrained like a normal user
  - e.g. System Administrators

#### Service Provider (SP)
- Provides services to the FoI
  - Communications
  - Shared databases
  - Internet access
- Controllers of service, could compromise any security

#### Service Consumer (SP)
- Makes use of services advertised/provided by the FoI
- e.g. user of 'walk in' kiosk

#### Shared Service Subscribers (SSS)
- Someone who is an authorised user of services used by the FoI
- Not a registered user of the systems/services within the FoI
- e.g. FoI may rely on same power distribution service as user, user could
  make it unavailable, affecting FoI

#### Supplier (SUP)
- Someone in supply chain that provides, maintains, has access to
  software/equipment
- May have knowledge to allow/facilitate compromise of security property

## Defense in Depth
- Idea that multiple defences add security
- If one defense is breached, many still stand
- Defences must be independent
  - Physically, logically and in tools required to break

### Attack Trees
- Build a tree with attacker goal at the top
- Various ways of achieving attack descend from the goal

<img src="https://i.imgur.com/RZtBfql.png" style="width: 35em;" />

## Risk Appetite and Residual Risk(24/10/2017)
### Alternatives to controls
- **Transfer** a risk, by outsourcing
- **Accept** a risk

### Risk Treatment
- Iteratively develop a risk treatment plan
  - Apply controls
  - Look at residual risk (remaining likelihood/impact)
  - Assess whether residual risk is OK
  - Repeat
- Each step should reduce likelihood or impact of risk
- Zero risk is unachievable
  - Get risk as low as reasonably possible
  - Costs will get in the way of removing risk

### Risk Treatment Cost
- Simple to put price on risk treatments
- Hard to calculate return

### Side Effects
- **Direct**
  - Consequences of imposing the control, unrelated to use response
  - e.g. tighter email policies, issues when staff travel
- **Indirect**
  - Consequences of imposing control
    - Users work around control etc.
  - User's working around policy may be worse than original risk
  - e.g. tighter email policies, staff redirect email to personal account

### What is insurance?
- Bet on an event happening
- Person taking out insurance "wins" if even occurs and they receive payment
- Insurer prices their bet based on likelihood

### Self-insurance
- If you can afford the maximum payout
- Put money in the bank

### Risk Acceptance
- Not paying insurance for cheap risks
- Insurance for more expensive risk

### Risk Appetite
- Decision on which risks to insure against depends on risk appetite
- Companies often take policies with large excesses to reduce insurance cost
  - Partially self-insuring

### Cost of Failure
- Fines from ICO
- Reputation harm

## Testing the System
### Tiger Teaming
- Penetration testing - employed to break security
- Tests security policy and execution
- Positive results
  - Presume good security measures
- Negative results
  - Shows a flaw, how it was used, how to fix
  - Could be policy, implementation or execution
- Problems
  - Tiger team can't hold a gun to your head or blackmail :(
  - Motivations different to an attacker
  - Likely won't focus on personnel weaknesses or internal processes

### War Gaming
- Attempt to abuse policies with paper copies to hand
- Unrealistic

## Metrics
### Proxy Outcomes
- Easy to focus on what we see a lot of e.g. packets blocks, viruses detected
- If we see more viruses detected are we doing better or worse?

### Audit
- Is process being followed, controls in place, records being kept?
- Is process worthwhile, controls meet objectives?
- Can graph number of successful audits and actions raised

## Governance
### Small Companies
- Owner, CEO, COO and shareholders may be same person or same small group
- Decisions signed off by them
- No oversight on decision making

### Large Companies
- Big decisions by committees
- Board report to shareholders via AGM
- Operational committees report to CEO and other board members

### Ideal Structure
- Security team led by Chief Security Officer (CSO)
- Team perform risk assessment, produce treatment plan, define residual risk
- Present findings to CEO/Board
- If agreed, Chief Info Officer (CIO) does what the board says

### Section 404
- Management must report financial risk to shareholders and the SEC
- Looks at threat actors aiming at company's money/success
- Looks at controls
- Establishes residual risk
- IT:
  - Access to funds/stock
  - Access to customer data
  - Accuracy of reporting

### Security Governance Committee
- IT decision making, part of legally-accountable corporate structure
- IT governance needs same controls/accountabilities as finance
- Committee drawn from whole business
  - IT, Finance, HR minimum
- Ideally report to board or CEO
- CEO resolves conflict
- CSO/CIO present paper for approval from committee on big decisions
- Detailed minutes for accountability

## ISO 27005 Risk Management
- Supporting standard of 27001 ("Plan Do Check Act")
- Provides info for designing own risk management system
- A means to check risk management strategy is sensible

### Section 3: Vocabulary
- Clear definitions of often-used terms

### Section 7: Context Establishment
- Very similar to IS1 impact levels
  - We don't just use IS1 because that's aimed at government with super-uber
    classified data
- Determining scope/FoI

### Section 8: Risk Assessment
- Risk: consequences and likelihood
- 8.2.2 asset register, 8.2.3 threat actors, 8.2.4-5 existing position,
  8.2.6 impact levels for CIA

### Section 9: Risk Treatment
- Slightly different wording
- Modification
  - Risk reduction and mitigation
- Retention
  - Reducing risk and accepting remaining
- Avoidance
  - Transfer risk
  - Don't do the thing that has risk...
- Sharing
  - Transfer risk partially

### Section 10: Risk Acceptance
- Residual risk to be formally signed off

### Section 11: Communication and Consultation
- Training, governance and discussion

### Section 12: Monitoring and Review
- Is anything changing?
- Is it working?

### Annexes
- Contains lots of useful stuff as a good starting point
- e.g. compromise methods, assets, threats

## Information Security Management Systems (ISMS)
- Scope the ISMS (Information Security Management Systems)
- Build asset register
- Analyse threats
- Build risk register
- Impose controls
- Operate and measure
- Improve


- Hard to get existing company to:
  - Rent kit
  - Replace old kit (time and money was put into)
  - Change everything in a short time
  - Change in general
- Existing processes
  - Must be analysed
    - May be useful
    - May be a waste of time
- Existing staff
  - May need new staff with skills
  - May no longer need old staff
