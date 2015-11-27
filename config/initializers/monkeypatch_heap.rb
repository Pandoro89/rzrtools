require 'algorithms'

class Containers::Heap
  def pop
    return nil unless @next
    popped = @next
    if @size == 1
      clear
      return popped.value
    end
    # Merge the popped's children into root node
    if @next.child
      @next.child.parent = nil
      
      # get rid of parent
      sibling = @next.child.right
      until sibling == @next.child
        sibling.parent = nil
        sibling = sibling.right
      end
      
      # Merge the children into the root. If @next is the only root node, make its child the @next node
      if @next.right == @next
        @next = @next.child
      else
        next_left, next_right = @next.left, @next.right
        current_child = @next.child
        @next.right.left = current_child
        @next.left.right = current_child.right
        current_child.right.left = next_left
        current_child.right = next_right
        @next = @next.right
      end
    else
      @next.left.right = @next.right
      @next.right.left = @next.left
      @next = @next.right
    end
    #consolidate
    
    @stored[popped.key].delete(popped)
    #unless @stored[popped.key].delete(popped)
    #   raise "Couldn't delete node from stored nodes hash" 
    # end
    @size -= 1
    
    popped.value
  end
end