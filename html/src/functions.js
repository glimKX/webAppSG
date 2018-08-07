
function removeAllText(element) {

    // loop through all the nodes of the element
    var nodes = element.childNodes;

    for(var i = 0; i < nodes.length; i++) {

        var node = nodes[i];

        // if it's a text node, remove it
        if(node.nodeType == Node.TEXT_NODE) {

            node.parentNode.removeChild(node);


            i--; // have to update our incrementor since we just removed a node from childNodes

        } else

        // if it's an element, repeat this process
        if(node.nodeType == Node.ELEMENT_NODE) {

            removeAllText(node);

        }
    }
}
