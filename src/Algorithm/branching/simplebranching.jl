@with_kw struct NewSimpleBranching <: AbstractDivideAlgorithm
    selection_criterion::Function
end

# algo.rules, PrioritisedBranchingRule(SingleVarBranchingRule(), 1.0, 1.0)

function run!(::NewSimpleBranching, env::Env, reform::Reformulation, input::DivideInput)
    println("\e[35m *** new simple branching *** \e[00m")
    return []
end

