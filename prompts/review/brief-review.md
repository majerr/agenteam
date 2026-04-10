Please conduct a review of the brief at {{BRIEF_PATH}}.

Use the following parameters throughout — they must be consistent across all agents and the synthesis:
- review-id: {{REVIEW_ID}}
- review-name: {{REVIEW_NAME}}
- output directory: {{OUTPUT_DIR}}

Instructions:

* Invoke the following agents sequentially, one at a time, passing the review-id, review-name, output directory, and brief path to each:
  - software-architect
  - tech-lead
  - devops-lead
  - cyber-security-lead

* Report progress as you go. Report any errors or messages from the agents.

* If an Agent tool call fails with a rate limit error (429), **DO NOT RETRY**. Stop immediately and report:
  "RATE_LIMIT_ERROR: {subagent_name}"

* When all agents have completed, synthesize their reviews into a single document in {{OUTPUT_DIR}}, named:
  {yyyymmdd}-{{REVIEW_ID}}-{{REVIEW_NAME}}-synthesis.md

* The synthesis must include:
  - A list of tasks that humans need to perform, prioritized as now / next / later
  - A list of tasks that can be actioned immediately by an AI agent, if any
  - Any tensions or contradictions that arise between the different reviews
