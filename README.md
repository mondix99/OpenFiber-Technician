# OpenFiber-Technician System

Overview

This project started as a graduation project inspired by real-world problems in the fiber optic field operations industry.

The idea came after observing the daily workflow of a field technician working in fiber installation and maintenance. Over time, I became increasingly interested in understanding how the operational side actually works — not only for technicians, but also for supervisors responsible for managing teams, assignments, and daily dispatch operations.

What initially looked like a “simple technician app” quickly evolved into a much larger system design challenge involving workflows, task distribution, execution tracking, coordination between teams, and integration with existing company systems.

⸻

The Problem

Through continuous observation and discussions with technicians and supervisors, I noticed several recurring operational challenges:

* Daily task assignments were difficult to organize efficiently
* Supervisors had to manually filter tasks by location, POP, or region
* Team distribution changed frequently based on workload
* Execution tracking was fragmented and difficult to monitor
* Communication between dispatchers, technicians, support teams, and scheduling systems lacked structure
* Many workflows relied heavily on manual coordination

The more I explored the domain, the more I realized that the real complexity was not in building screens, but in designing a scalable operational workflow system.

⸻

Understanding the Workflow

The field operation process generally revolves around two main categories:

1. Installation

New fiber line installation and activation for customers.

2. Repair / Maintenance

Troubleshooting, fault detection, and technical repair operations.

Each workflow contains multiple execution steps, validations, media uploads, signatures, status tracking, and operational checks.

⸻

Project Goals

The goal of this project was to design a system that could simplify and structure the execution workflow for both supervisors and field technicians.

The system was divided into two major parts:

Technician Mobile Application

A mobile interface for technicians to:

* Receive assigned tasks
* Follow step-by-step execution flows
* Submit technical data
* Upload photos/videos
* Complete signatures and reports
* Track execution progress
* Validate required operational steps

⸻

Dispatch / Supervisor Dashboard

A dashboard interface designed for supervisors to:

* Create daily teams
* Assign workers dynamically
* Organize tasks by POP or region
* Monitor task execution
* Track worker activity
* Manage dispatch operations visually

⸻

Technical Exploration

During development, I explored several architectural concepts including:

* MVVM architecture
* State-driven navigation
* Workflow engines
* Unified task models
* Multi-source task importing
* Execution state tracking
* Dashboard-based dispatch systems

I also experimented with:

* SwiftUI
* React Native / Expo
* Zustand state management
* Dashboard prototyping using Vercel v0
* System architecture planning
* Task ingestion pipelines (PDF import / external systems)

⸻

A Key Realization

One of the most important lessons from this project was realizing how large real operational systems actually are.

At a certain point, it became clear that building a production-ready field operations platform would require:

* Integration with internal company systems
* Real-time synchronization
* Scheduling infrastructure
* Backend services and APIs
* Support systems
* Authentication and permission layers
* Scalable database architecture
* Complex operational workflows

This project helped me understand the difference between:

building an interface
and
designing an operational system.

⸻

About AI Usage

AI tools such as Cursor and Vercel v0 were used during prototyping and experimentation phases to accelerate UI iteration and explore architectural ideas.

However, the core challenge of this project was not generating interfaces — it was understanding the workflow itself, analyzing operational pain points, and attempting to design a coherent system around real-world execution processes.

⸻

Current Status

The project is currently paused.

Not because the idea failed, but because the scope grew significantly larger than initially expected. I decided to stop temporarily rather than continue building without a clear long-term architecture and integration strategy.

Despite that, this project became one of the most valuable learning experiences in my journey as a developer.

It changed the way I think about:

* software architecture
* workflow systems
* operational design
* scalability
* and real-world problem solving.

⸻

Final Thoughts

This project started with curiosity.

It later became an exploration into how real operational systems work behind the scenes — and how much thought, structure, and coordination are required to make them reliable.

Even though the system is incomplete, the process of analyzing, designing, and attempting to model these workflows taught me far more than building a simple CRUD application ever could.

