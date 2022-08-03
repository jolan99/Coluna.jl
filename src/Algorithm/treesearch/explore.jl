struct DepthFirstStrategy <: AbstractExploreStrategy end

abstract type BestFirstSearch <: AbstractExploreStrategy end
struct CustomBestFirstSearch <: BestFirstSearch end
struct BestDualBoundStrategy <: AbstractExploreStrategy end

function tree_search(::DepthFirstStrategy, space, env, input)
    root_node = new_root(space, input)
    stack = Stack{typeof(root_node)}()
    push!(stack, root_node)
    while !isempty(stack) # and stopping criterion
        current = pop!(stack)
        for child in children(space, current, env)
            push!(stack, child)
        end
    end
    return tree_search_output(space)
end

function tree_search(strategy::BestFirstSearch, space, env, input)
    root_node = new_root(space, input)
    pq = PriorityQueue{typeof(root_node), Float64}()
    enqueue!(pq, root_node, priority(strategy, root_node))
    while !isempty(pq) # and stopping criterion
        current = dequeue!(pq)
        for child in children(space, current, env)
            enqueue!(pq, child, priority(strategy, child))
        end
    end
    return tree_search_output(space)
end