# Secure System Management

## Introduction (26/09/2017)

### Content
- Asset registers
  - What are we securing and why?
- Risk and threat analysis and modelling
  - What are we securing against?
  - Who are the attackers?
  - How motivated/prepared are they?
- Change management
  - How do we deal with new assets and threats?
  - How do we maintain existing security mechanisms and currently working/running systems?
- Metrics and audit
  - How do we know how well we are doing?
  - Is 'it' being done at all?

### Methodologies
- ISO 27001 for information security management systems
- ISO 27005 for risk modelling
- HMG Information Security Standard 1 (UK gov certified programme)
- ISO 22301/22313 for business continuity

## CIA (28/09/2017)
- Confidentiality
  - Can data only be read by authorised?
- Integrity
  - Can data only be changed by authorised?
- Availability
  - Is data always available to authorised?

### Conventional Ratings
- Rated on 5, sometimes 6 point scale of "impact"
- 1 = "no or trivial impact"
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
- "Undermine the financial viability of a minor UK based or UK-owned organisation"

#### IL 6
- "Lead directly to widespread loss of life"
- "Major, long term damage to the UK economy (to an estimated total in excess of £10 billion)"
- "Major, long term damage to global trade or commerce, leading to prolonged recession or hyperinflation in the UK"

### Exercises/Suggestions
- A load of suggestions in the slides for stuff. Will probably go into detail later.

### Cycle of Quality Systems (03/10/2017)
- Plan
  - Identify assets, risks, threats
  - Associate controls
- Do
  - Run the system with new controls
- Check
  - Design and collect metrics
  - Design and collect audit info
  - Assess (the best you can) the security of the system
- Act
  - Improve the system
  - Return to "do" (or "plan")
  - Repeat


- ISO 9001

## Manufacturing
- **Policies:** state objectives and criteria of system
- **Procedures:** state how to do things, check to ensure fulfilment of policy objectives
- **Work Instructions** or **Method Statements:** done in more detail
- **Quality Records audited:** compliance checked with policies and procedures

### Compliance
- {fill}

### Governance
- Documents approved by named people who are accountable
- Review dates
- Issue/version control
- A way to get "latest" copy, protection against old copies
- Documents flow from requirements

### Document hierarchies
- 27001 offers guidance, other standards may be considered
- {missing info}

### Policies
- Describe how things should be, not how to do them
- Sets objectives and high-level operational requirements
- Written by senior managers, approved by other senior managers or board-level directors
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
- Describe how to do something correctly
- Can be checked against policies to confirm they implement requirements and objectives (should state which policies they are derived from)
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
- **Threat source:** a person/organisation that desires to breach security and benefit
- **Threat actor:** a person that performs an attack
- **Threat level:** a level attributed to the to capability/motivation of a threat actor/source to an asset


**Deterrable?**
- Threat to lose job, clearance, livelihood, liberty...
- Appeal to "better nature", ethical codes, etc.

#### Compromise methods
- How an attack may be carried out
- Only considers methods plausible for identified threat sources

#### Risks
- Risks are things that might happen to an asset, combining likelihood with impact
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
