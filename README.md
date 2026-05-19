# OpenFiber-Technician System

## Overview

This project started as a graduation project inspired by real-world problems in fiber optic field operations.

The idea came after observing the daily workflow of technicians working in fiber installation and maintenance. Over time, I became increasingly interested in understanding how operational systems actually work behind the scenes — not only from the technician perspective, but also from the dispatcher and supervisor side responsible for organizing teams, assignments, and daily operations.

What initially looked like a “simple technician mobile app” quickly evolved into a much larger system design challenge involving:

- task distribution
- execution workflows
- team coordination
- real-time tracking
- dispatch operations
- workflow validation
- system integration
- and scalable operational architecture

At a certain point, I realized the real complexity was not in building screens — it was in designing the operational system itself.

---

# The Problem

Through continuous observation and discussions with technicians and supervisors, I noticed several recurring operational challenges:

- Daily task assignments were difficult to organize efficiently
- Supervisors manually filtered tasks by POP, region, or priority
- Team distribution changed dynamically based on workload
- Execution tracking was fragmented and difficult to monitor
- Communication between dispatchers, technicians, support teams, and scheduling systems lacked structure
- Many operational flows relied heavily on manual coordination

The deeper I explored the workflow, the clearer it became that field operations are essentially large-scale coordination systems rather than simple task lists.

---

# Understanding the Workflow

The operational process mainly revolved around two major categories:

## 1. Installation

New customer fiber installation and activation workflows.

## 2. Repair / Maintenance

Fault detection, troubleshooting, maintenance, and technical repair operations.

Each operation contains multiple execution steps, validations, media uploads, signatures, state transitions, and operational checks.

This led me to think less about “screens” and more about workflow states, execution logic, and lifecycle management.

---

# Project Goal

The goal of this project was not simply to create a UI prototype.

The real goal was to explore how a scalable field operations platform could be structured and coordinated.

The system was divided into two main environments:

---

# Technician Mobile Application

A mobile-first interface designed for field technicians to:

- Receive assigned tasks
- Follow step-by-step execution flows
- Submit technical reports
- Upload photos and videos
- Complete signatures
- Track execution progress
- Validate operational requirements
- Update task states in real time

---

# Dispatch / Supervisor Dashboard

A management interface designed for supervisors to:

- Create daily teams
- Assign technicians dynamically
- Organize tasks by POP or geographic region
- Monitor live execution progress
- Track worker activity
- Manage dispatch operations visually
- Analyze operational flow and bottlenecks

---

# Technical Exploration

During development, I explored several architectural and workflow concepts including:

- MVVM architecture
- State-driven navigation
- Workflow engines
- Unified task models
- Multi-source task importing
- Execution lifecycle tracking
- Dispatch coordination systems
- Real-time synchronization concepts

I also experimented with:

- SwiftUI
- React Native / Expo
- Zustand state management
- Dashboard prototyping using Vercel v0
- Interactive architecture visualization
- System planning and operational modeling
- Task ingestion pipelines from external systems and PDFs

---

# Interactive Architecture Visualization

To better communicate the system structure and operational flow, I created an interactive architecture presentation that visualizes:

- system architecture
- backend separation
- data flow
- task lifecycle
- dispatch coordination
- technician workflow execution
- real-time synchronization concepts

The purpose of the presentation was not simply visual design.

It was created to demonstrate the thinking process behind the system:
how the workflows were analyzed, how responsibilities were separated, and how the operational logic was planned before full implementation.

🔗 Live Interactive Demo:

https://fiber-ops-manager--newforvercel1.replit.app/

---

# A Major Realization

One of the biggest lessons from this project was understanding how large real operational systems actually are.

At some point, it became clear that building a production-ready field operations platform would require:

- integration with internal company systems
- scalable backend infrastructure
- real-time synchronization layers
- scheduling systems
- authentication & permission management
- operational analytics
- distributed services
- cloud storage infrastructure
- scalable databases
- and long-term architectural planning

This project helped me understand the difference between:

building interfaces

and

designing operational systems.

---

# About AI Usage

AI tools such as Cursor, Claude, and Vercel v0 were used during experimentation and prototyping phases to accelerate UI iteration and architectural exploration.

However, the core challenge of this project was never generating interfaces.

The real challenge was understanding the operational workflow itself, identifying pain points, modeling execution logic, and attempting to design a coherent system around real-world field operations.

---

# Current Status

The project is currently paused.

Not because the idea failed, but because the scope expanded far beyond the original expectations.

Rather than continuing with fragmented implementation decisions, I chose to stop temporarily and focus on understanding the architecture, scalability concerns, and operational requirements more deeply before moving further.

Even without being fully completed, this project became one of the most valuable learning experiences in my development journey.

It significantly changed the way I think about:

- software architecture
- workflow systems
- operational coordination
- scalability
- distributed responsibilities
- and real-world engineering problems

---

# Final Thoughts

This project started with curiosity.

Over time, it became an exploration into how real operational systems function behind the scenes — and how much structure, coordination, planning, and system thinking are required to make them reliable.

Even though the platform remains incomplete, the process of analyzing workflows, designing architecture, and attempting to model real operational behavior taught me far more than building a typical CRUD application ever could.
