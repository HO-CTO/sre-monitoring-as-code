<template>
  <div class="modal" id="modal-1" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <a href="#" class="close" role="button" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </a>
        <slot></slot>
        <div class="text-right mt-20">
          <!-- text-right = text-align: right, mt-20 = margin-top: 2rem (20px) -->
          <a href="#" class="btn mr-5" role="button">Close</a>
          <a href="#" class="btn btn-primary" role="button">I understand</a>
        </div>
      </div>
    </div>
  </div>
</template>
