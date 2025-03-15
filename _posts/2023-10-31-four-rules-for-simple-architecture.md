---
layout: post
title: 4 Rules For Simple Architecture
author: Kenan Sevindik
---

Simplicity in software systems and architecture has always been an elusive but vital goal for software engineers. 
The pursuit of clear, efficient, and adaptable solutions is at the core of creating software that not only meets 
immediate needs but also gracefully accommodates change. In this blog post, I will detail the "4 Rules for a Simple 
Architecture," how I formulated these rules, and how these architectural principles can help you streamline the design 
and decision-making process.

## How Did I Formulate These 4 Rules?

As I set out to identify guiding principles for a simpler architectural approach to govern my software design and 
development activities, I found myself inspired by an anecdote from Kent Beck about how he formulated the four rules of 
simple design. Here is an excerpt he shared on his Facebook page, in which he tells the story:

> "As I was coming up as an engineer, the advice I always heard was, 'Design for the future. Change is expensive. Make 
> it cheap by anticipating it.' What I noticed in practice was that the more change I anticipated, the harder it got to 
> make changes. My incorrect speculations interfered with changes I actually ended up making. Then I would have to choose 
> between working around speculative cruft or ripping it out, both of which delayed progress on what I was trying to 
> accomplish.
>
> I wasn’t alone. Lots of folks noticed the cost of speculation. The prevailing response seemed to be that we just 
> weren’t good enough at speculation. If we were better speculative designers, we would end up with better designs. 
> This looked like a positive feedback loop to me: more speculation -> worse design -> more speculation.
>
> The good news about disastrous positive feedback loops is that you can generally drive them backwards. I first 
> experimented by ignoring any changes that seemed like they would happen longer than six months in the future. My 
> designs were simpler, I started making progress sooner, and I stressed less about the unknowable future. I shortened 
> the time horizon to three months. More better. One month. More. A week. A day. Oh, hell, what happens if I don’t add 
> any design elements not demanded by the current code and tests? Still more better.
>
> Now I had an ethos of software design, but I stupidly labeled it 'simple.' Talk about a vague, loaded word that 
> everyone will use to justify exactly what they are doing now. I soon tired of debating what 'simple' 'really' meant. 
> I needed a clear explanation.
>
> My approach to communicating complex ideas at the time was to formulate a simple set of rules, the emergent property 
> of which was the complex outcome I was aiming at (cf. patterns). (I have since become disenchanted with this strategy.) 
> I thought about how I recognized simplicity, turned those criteria into actions, sorted them by priority (it’s no 
> coincidence that human communication is number two), and posted them on Ward’s Wiki¹. And that’s why (and how) I wrote
> the rules."

### The 4 Rules of Simple Design:

1. **Runs All The Tests**
2. **Clear, Expressive & Consistent**
3. **No Duplicated Behavior & Configuration**
4. **Fewest Possible Classes and Methods**

As Beck noted, these rules are ordered by priority. If there is any conflict between them, the higher one on the list 
should take precedence.

The ultimate goal of these rules is to establish a sustainable pace for delivering features by focusing primarily on 
intended functionality and avoiding unnecessary details. In other words, the goal is to move fast.

I started thinking about how beneficial it would be if we had a set of fundamental guiding principles when discussing 
the architectural aspects of our software systems. Similar to Beck’s rules, the primary focus of these architectural 
rules should be striving for simplicity.

## Introducing the 4 Rules for a Simple Architecture

### **Rule 1: Architecture is about use cases**

The primary purpose of developing a software system is to satisfy business or user requirements as directly as possible. 
Every part of the solution and design artifact should have a direct relationship with real business needs. Focusing on 
use cases ensures that architecture aligns with functional requirements and helps prioritize architectural decisions 
based on actual user needs. The end result is a software system that better serves its intended purpose.

_(This rule's name was inspired by Uncle Bob, who has often emphasized that "architecture is about use cases" in his 
writings and talks.)_

### **Rule 2: Architecture is about cost reduction**

This rule forces architects to consider the long-term implications of architectural choices on maintenance and operational 
expenses. One of the primary skills of a successful software architect is the ability to defer decisions until the latest 
possible moment. Delaying decisions until they are truly necessary often leads to more efficient and cost-effective solutions.

### **Rule 3: Architecture should be evolvable**

Requirements change, technology changes, environments change. The only constant is change itself. Our solutions must be 
adaptable to future changes. This rule encourages a flexible and modular design, making it easy to add or modify features. 
Architecture should be open to continuous improvement and allow for iterative development.

### **Rule 4: Programmers are Architects & Architects are Programmers**

Software architecture is not an elite activity reserved for a select few engineers. Every developer contributes to the 
architecture of a system. This rule underscores the importance of clear communication and collaboration across the entire 
organization. Architectural contributions should be open to all engineers, making it easy for any programmer to share 
ideas, raise concerns, and contribute to workable solutions that shape the architecture.

_(This rule was also inspired by Uncle Bob, who has long advocated for the idea that architects should remain hands-on 
and actively involved in coding.)_

Much like the four rules of simple design, these four rules for simple architecture are ordered by priority. In cases of 
conflicts in architectural decisions, the higher-ranked rules should take precedence over the lower ones.

## Conclusion

These architectural guidelines—emphasizing use cases, cost reduction, adaptability, and inclusivity—offer a path toward 
resilient, cost-effective, and user-centric software systems. By adhering to these rules, you can ensure that your 
software architecture evolves gracefully with the ever-changing landscape of technology and user needs while maintaining 
the clarity and simplicity that define great software.

As you embark on your journey to architectural excellence, remember that, like the rules of simple design, these 
architectural rules can be your guiding light, helping you navigate the complexities of software development with finesse 
and agility.

