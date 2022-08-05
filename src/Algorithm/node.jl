####################################################################
#                      Node
####################################################################

mutable struct Node <: AbstractNode
    tree_order::Int
    istreated::Bool
    depth::Int
    parent::Union{Nothing, Node}
    optstate::OptimizationState
    branchdescription::String
    recordids::RecordsVector
    conquerwasrun::Bool
end

parent(node::Node) = node.parent
root(node::Node) = isnothing(parent(node)) ? node : root(parent(node))

## TODO remove is possible
isrootnode(node::Node) = isnothing(parent(node))
getdepth(n::Node) = n.depth
getoptstate(n::Node) = n.optstate
get_tree_order(n::Node) = n.tree_order
set_tree_order!(n::Node, tree_order::Int) = n.tree_order = tree_order


# Node for strong branching
mutable struct SbNode 
    tree_order::Int
    istreated::Bool
    depth::Int
    parent::Union{Nothing, Node}
    optstate::OptimizationState
    #branch::Union{Nothing, Branch} # branch::ConstrId
    branchdescription::String
    recordids::RecordsVector
    conquerwasrun::Bool
end


# mutable struct Node 
#     tree_order::Int
#     istreated::Bool
#     depth::Int
#     parent::Union{Nothing, Node}
#     optstate::OptimizationState
#     #branch::Union{Nothing, Branch} # branch::ConstrId
#     branchdescription::String
#     recordids::RecordsVector
#     conquerwasrun::Bool
# end

# function RootNode(
#     form::AbstractFormulation, optstate::OptimizationState, recordrecordids::RecordsVector, skipconquer::Bool
# )
#     nodestate = OptimizationState(form, optstate, false, skipconquer)
#     tree_order = skipconquer ? 0 : -1
#     return Node(
#         tree_order, false, 0, nothing, nodestate, "", recordrecordids, skipconquer
#     )
# end

function SbNode(
    form::AbstractFormulation, parent::Node, branchdescription::String, recordrecordids::RecordsVector
)
    depth = getdepth(parent) + 1
    nodestate = OptimizationState(form, getoptstate(parent), false, false)
    
    return SbNode(
        -1, false, depth, parent, nodestate, branchdescription, recordrecordids, false
    )
end

# this function creates a child node by copying info from another child
# used in strong branching
function Node(parent::Node, child::SbNode)
    depth = getdepth(parent) + 1
    return SbNode(
        -1, false, depth, parent, getoptstate(child),
        child.branchdescription, child.recordids, false
    )
end

function Node(node::SbNode)
    return Node(node.tree_order, node.istreated, node.depth, node.parent, node.optstate, node.branchdescription, node.recordids, node.conquerwasrun)
end


# getchildren(n::Node) = n.children
getoptstate(n::SbNode) = n.optstate
# addchild!(n::Node, child::Node) = push!(n.children, child)
# settreated!(n::Node) = n.istreated = true
# istreated(n::Node) = n.istreated
# getinfeasible(n::Node) = n.infesible
# setinfeasible(n::Node, status::Bool) = n.infeasible = status

# # TODO remove
# function to_be_pruned(node::Node)
#     nodestate = getoptstate(node)
#     getterminationstatus(nodestate) == INFEASIBLE && return true
#     return ip_gap_closed(nodestate)
# end
