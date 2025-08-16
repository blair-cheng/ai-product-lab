from bayesnet import BayesNet, BayesNode
def ask(var, value, evidence, bn):

	"""
	rule chain: p(b,e,a) = p(e,a|b)*p(b)
	p(e,a|b) = p(e|b) * p(a|b,e)

	return P(H|E) = P(H,E)/alpha
	alpha = P(E) = P(H, E) + P(-H, E)

	input: 
		var: H name
		value: H true or false
		evidence: E(name, true or false)
		bn
	output: P(var|evidence)
	"""
	# get variables from dictionary of bn
	variables = bn.variable_names

	# create new evidence and set var = true
	evidence_true = {**evidence, var: True}
	# p(h=true,e)
	phe = joint_probability(variables, evidence_true, bn)

	# create new evidence and set var = false 
	evidence_false = {**evidence, var: False}
	# p(h=false,e)
	pnhe = joint_probability(variables, evidence_false, bn)

	# p(e) = p(e,h) + p(e, -h)
	alpha = phe + pnhe

	# P(var|evidence) = p(h,e)/p(e) 
	return (phe if value else pnhe )/alpha if alpha > 0 else 0



def joint_probability(variables, evidence, bn):
	"""
	input: variables, evidence dictionary 
	output: p(v1,v2,...,vn)
	"""
	# return 1.0 when finished 
	if not variables:
		return 1.0

	# get the node to be processed
	var = variables[0]
	rest = variables[1:]
	node = bn.get_var(var)
	
	if var in evidence:
		# prob = p(var|evidence )
		prob = node.probability(evidence[var], evidence)
		return prob * joint_probability(rest, evidence, bn)
		
	else:
		# if var not in evidence
		# set var = true and add to evidence 
		evidence_true = {**evidence, var: True}
		# jphe = p(var=true|e) * p(rest=true|e,var = true) 
		jphe = node.probability(True, evidence) * joint_probability(rest, evidence_true, bn)

		# then set var = false and add to evidence 
		evidence_false = {**evidence, var: False}
		# jpnhe = p(var = false|e)* p(rest=true|e,var = false ) 
		jpnhe = node.probability(False, evidence) * joint_probability(rest, evidence_false, bn)
		return jphe + jpnhe
