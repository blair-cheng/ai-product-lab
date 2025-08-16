import read, copy
from util import *
from logical_classes import *

verbose = 1

class KnowledgeBase(object):
    def __init__(self, facts=[], rules=[]):
        self.facts = facts
        self.rules = rules
        self.ie = InferenceEngine()

    def __repr__(self):
        return 'KnowledgeBase({!r}, {!r})'.format(self.facts, self.rules)

    def __str__(self):
        string = "Knowledge Base: \n"
        string += "\n".join((str(fact) for fact in self.facts)) + "\n"
        string += "\n".join((str(rule) for rule in self.rules))
        return string

    def _get_fact(self, fact):
        """INTERNAL USE ONLY
        Get the fact in the KB that is the same as the fact argument

        Args:
            fact (Fact): Fact we're searching for

        Returns:
            Fact: matching fact
        """
        for kbfact in self.facts:
            if fact == kbfact:
                return kbfact

    def _get_rule(self, rule):
        """INTERNAL USE ONLY
        Get the rule in the KB that is the same as the rule argument

        Args:
            rule (Rule): Rule we're searching for

        Returns:
            Rule: matching rule
        """
        for kbrule in self.rules:
            if rule == kbrule:
                return kbrule

    def kb_add(self, fact_rule):
        """Add a fact or rule to the KB
        Args:
            fact_rule (Fact or Rule) - Fact or Rule to be added
        Returns:
            None
        """
        printv("Adding {!r}", 1, verbose, [fact_rule])
        # if fact_rule is fact
        if isinstance(fact_rule, Fact):
            if fact_rule not in self.facts:
                self.facts.append(fact_rule)
                # compare the fact with each rules to make inference
                for rule in self.rules:
                    self.ie.fc_infer(fact_rule, rule, self)
            # if fact_rule already in self.fact
            else:
                # if fact_rule have supported_by, find fact_rule's index in self.fact
                if fact_rule.supported_by:
                    ind = self.facts.index(fact_rule)
                    # add supported_bys to this fact_rule in facts
                    for f in fact_rule.supported_by:
                        self.facts[ind].supported_by.append(f)
                else:
                    ind = self.facts.index(fact_rule)
                    self.facts[ind].asserted = True
        # if fact_rule is rule
        elif isinstance(fact_rule, Rule):
            if fact_rule not in self.rules:
                self.rules.append(fact_rule)
                for fact in self.facts:
                    self.ie.fc_infer(fact, fact_rule, self)
            # if fact_rule in self.fact
            else:
                if fact_rule.supported_by:
                    ind = self.rules.index(fact_rule)
                    for f in fact_rule.supported_by:
                        self.rules[ind].supported_by.append(f)
                else:
                    ind = self.rules.index(fact_rule)
                    self.rules[ind].asserted = True

    def kb_assert(self, fact_rule):
        """Assert a fact or rule into the KB

        Args:
            fact_rule (Fact or Rule): Fact or Rule we're asserting
        """
        printv("Asserting {!r}", 0, verbose, [fact_rule])
        self.kb_add(fact_rule)

    def kb_ask(self, fact):
        """Ask if a fact is in the KB

        Args:
            fact (Fact) - Statement to be asked (will be converted into a Fact)

        Returns:
            listof Bindings|False - list of Bindings if result found, False otherwise
        """
        print("Asking {!r}".format(fact))
        # if fact is a valid Fact
        if factq(fact):
            # convert fact into standard Fact object
            f = Fact(fact.statement)
            bindings_lst = ListOfBindings()
            # ask matched facts
            for fact in self.facts:
                # match parameter fact and self fact 
                binding = match(f.statement, fact.statement)
                if binding:
                    bindings_lst.add_bindings(binding, [fact])

            return bindings_lst if bindings_lst.list_of_bindings else []

        else:
            print("Invalid ask:", fact.statement)
            return []

    def kb_retract(self, fact_rule):
        """Retract删除 a fact or a rule from the KB

        Args:
            fact_rule (Fact or Rule) - Fact or Rule to be retracted

        Returns:
            None

        when remove a fact or a rule, 
        you also need to remove all facts and rules 
            that were inferred using this fact or rule. 
                (check supports_rules, supports_facts)
        However, you'll need to check 
            whether the facts and rules inferred from this fact or rule 
                (check supported_by of the supports_rules, supports_facts)
                (find if supported_by not only include this fact/rule)
                (or if they were directly asserted).

        As a simplification, you can assume that no rules will create circular dependencies. 
        
        Implementing kb_retract
        
        if fact_rule is Asserted and NOT have support 
            can be retracted.

        if fact_rule is Asserted and have support 
            cannot be retracted; 
            only be unasserted.

        if fact_rule is infered and NOT have support (when retracted a fact_rule,check it)
            shouldn’t even be existing 
            they should have been retracted when their supports were retracted.

        if fact_rule is infered and have support:
            cannot be retracted, (just do nothing)
            and there’s no unasserting needed 
            as they are already unasserted. 

        check (rules and facts) in supports_rules and supports_facts 
        of the retracted fact or rule supports:
            if  (rules and facts)' supported_by list 
                become empty as a result of the retraction 
                and if it is also not asserted, 
                it should be removed.
        
        """

        printv("Retracting {!r}", 0, verbose, [fact_rule])
        ####################################################
        # if fact_rule is fact
        if isinstance(fact_rule, Fact):
            # check it in KB
            target_fact = self._get_fact(fact_rule)
            if not target_fact:
                print("Fact not found in KB, retraction stopped.")
                return
            # if it is asserted
            if target_fact.asserted:
                target_fact.asserted = False

            # if fact have no supported_by and not asserted
            if not target_fact.asserted and not target_fact.supported_by:
                self.facts.remove(target_fact)

            # check it's supported facts
            for fact in target_fact.supports_facts[:]:
                fact.supported_by = [pair for pair in fact.supported_by if target_fact not in pair]
                if not fact.supported_by and not fact.asserted:
                    self.kb_retract(fact)

            for rule in target_fact.supports_rules[:]:
                rule.supported_by = [pair for pair in rule.supported_by if target_fact not in pair]
                if not rule.supported_by and not rule.asserted:
                    self.kb_retract(rule)
        
        # if fact_rule is rule
        elif isinstance(fact_rule, Rule):
            target_rule = self._get_rule(fact_rule)
            if not target_rule:
                print("Rule not found in KB, retraction stopped.")
                return
            if target_rule.asserted:
                target_rule.asserted = False

            if not target_rule.asserted and not target_rule.supported_by :
                self.rules.remove(target_rule)

            for rule in target_rule.supports_rules[:]:
                rule.supported_by = [pair for pair in rule.supported_by if target_rule not in pair]
                if not rule.supported_by and not rule.asserted:
                    self.kb_retract(rule)

            for fact in target_rule.supports_facts[:]:
                fact.supported_by = [pair for pair in fact.supported_by if target_rule not in pair]
                if not fact.supported_by and not fact.asserted:
                    self.kb_retract(fact)





class InferenceEngine(object):
    def fc_infer(self, fact, rule, kb):
        """Forward-chaining to infer new facts and rules

        Args:
            fact (Fact) - A fact from the KnowledgeBase
            rule (Rule) - A rule from the KnowledgeBase
            kb (KnowledgeBase) - A KnowledgeBase

        Returns:
            Nothing


        The key idea is that we don't just infer new facts 
        - we can also infer new rules.

        When we add a new fact to the KB, 
            we check to see if it triggers any rule(s). 
            
        When we add a new rule, 
            we check to see if it's triggered by existing facts.

        However, a rule might have multiple statements on its left-hand side (LHS), 
            Instead, 
            we'll only check the first element of the LHS of that rule against the facts in our KB. 
                If there's a match with this first element, 
                    we'll add a new rule paired with bindings for that match.

        For example, imagine a box-world. Consider a rule stating that 
        ((sizeIsLess(?y, ?x), on(?x, ?y)) => covered(?y))
            if we have the fact sizeIsLess(B, A) in the KB. 
                The above rule then matches with the bindings ((?x: A, ?y: B)). 
                we can now infer a new rule:(on(A, B)) => covered(B)
            If we find the fact on(A, B) in the KB, 
                then we can use this rule to infer the fact covered(B). 
            If we don't have that fact on(A, B)
                however, we now have a simple rule 
                that will let us make the inference easily 
                if we see that fact in the future.    


        Implementing fc_infer
        Use the util.match function 
            to do unification 
            and create possible bindings.
        Use the util.instantiate function 
            to bind a variable in the rest of a rule.

        Rules and Facts have fields for 
        supported_by, supports_facts, and supports_rules. 
            Use them to track inferences! 
            For example, imagine that a fact F and a rule R 
            matched to infer a new fact/rule fr.
                fr is supported by F and R. 
                Add them to fr's supported_by list of lists
                 - you can do this by passing them as a constructor argument 
                 when creating fr.
                F and R now support fr. 
                Add fr to the supports_rules and supports_facts lists 
                (as appropriate) in F and R.            
        """
        printv('Attempting to infer from {!r} and {!r} => {!r}', 1, verbose,
            [fact.statement, rule.lhs, rule.rhs])
        ####################################################
        # Student code goes here

        # match and create possible fact-rule bingdings 
        bindings = match(fact.statement, rule.lhs[0])
        if not bindings:
            return 
        
        # if infer with one condition or lhs decreased to one
        if len(rule.lhs) == 1:
            # Generate Statement
            new_fact_statement = instantiate(rule.rhs, bindings)
            # Create new Fact with supported_by
            new_fact = Fact(new_fact_statement, supported_by = [[fact, rule]] )

            # check if the new fact already in kb
            existing_fact = kb._get_fact(new_fact)
            if existing_fact:
                # if so, only add supported_by in kn
                existing_fact.supported_by.append([fact, rule])
            else:
                # if not already in kn, assert it into kb
                kb.kb_assert(new_fact)
                # update the supports_facts for the fact and rule we are processing with
                if new_fact not in fact.supports_facts:
                    fact.supports_facts.append(new_fact)
                if new_fact not in rule.supports_facts:    
                    rule.supports_facts.append(new_fact)
        # if lhs with multiple statement
        else:
            # Generate new lhs, rhs, rule
            new_lhs = [instantiate(stmt, bindings) for stmt in rule.lhs[1:]]
            new_rhs = instantiate(rule.rhs,bindings ) 
            new_rule = Rule([new_lhs, new_rhs], supported_by = [[fact, rule]])
            
            existing_rule = kb._get_rule(new_rule)
            # if new rule in KB, append fact, rule
            if existing_rule:
                existing_rule.supported_by.append([fact, rule])
            else:
            # if new rule not in KB, assert it in kb and add it in supports_rules 
                kb.kb_assert(new_rule)
                if new_rule not in fact.supports_rules:
                    fact.supports_rules.append(new_rule)
                if new_rule not in rule.supports_rules:
                    rule.supports_rules.append(new_rule)


        
