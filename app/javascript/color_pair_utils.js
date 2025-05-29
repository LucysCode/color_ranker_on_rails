// Color Pair Utility Functions

// Vote submission function
function submitPairVote(voteType, leftColor, rightColor) {
    fetch('/vote_pair', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        vote_type: voteType,
        left_color: leftColor,
        right_color: rightColor,
      })
    })
    .then(response => response.ok ? window.location.href = `/rank_color_pairs?new_pair=true&last_vote=${voteType}` : Promise.reject())
    .catch(error => console.error("Vote submission failed:", error));
  }
  
  // Mobile view toggle functions
  window.showResultsView = function() {
    document.body.className = 'mobile-results-view';
  }
  
  window.showMainView = function() {
    document.body.className = 'mobile-main-view';
  }
  
  // Sortable list position update
  function updatePosition(listId, newIndex, oldIndex, csrfToken) {
    const list = document.getElementById(listId);
    const orderedIds = Array.from(list.querySelectorAll('li')).map((li) => li.dataset.id);
  
    fetch('/pairs/update_position', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        ordered_ids: orderedIds,
        list_type: listId
      })
    }).then(response => {
      if (response.ok) {
        const items = list.querySelectorAll('li');
        items.forEach((item, index) => {
          const positionEl = item.querySelector('.position-number');
          if (positionEl) {
            positionEl.textContent = index + 1;
          }
        });
      } else {
        alert('Failed to update order');
      }
    });
  }
  
  // Setup sortable lists
  function setupSortable(listId, groupName) {
    const listElement = document.getElementById(listId);
    if (listElement) {
      new Sortable(listElement, {
        group: groupName,
        onEnd: function (evt) {
          const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
          updatePosition(listId, evt.newIndex, evt.oldIndex, csrfToken);
        }
      });
    }
  }