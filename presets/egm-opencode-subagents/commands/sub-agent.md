# Special Instruction - Sub-Agent Delegation

You will use @general subagent

Read `.specify/extensions/egm/agents/<file>.md` where <file> will be replaced by the persona you require.

| Subagent Persona | File Name |
| --- | --- |
| egm-codebase-details | codebase_details |
| egm-comprehension | comprehension |
| egm-design | design_critic |
| egm-implementation-readiness | implementation_readiness |
| egm-inventive-catalyst | inventive_catalyst |
| egm-structural | structural |
| egm-style | style |
| egm-synthesizer | synthesizer |
| egm-zoom-out | zoom_out |

Above files have frontmatter and you will extract `description` field from it

Invoking a subagent requires 3 properties -

* agentID = "general"
* description = description extracted from file
* prompt = body of the  file (i.e. content except for the front matter)
