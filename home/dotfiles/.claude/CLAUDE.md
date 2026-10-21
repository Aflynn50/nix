-- This file is managed by nix

Please do not push git branches origin unless the user has explicitly asked you to. 
Feature branches should remain local.

Once you have finished a large change, please check origin/main, if it has been updated since you started please rebased onto it and check that nothing there has affected your work.

When you fan out to sub agents, if the main thread is using Opus-5.5, please use Sonnet-5.5 for the subagents.
