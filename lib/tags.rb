def tags
  if @item[:tags].nil?
    '(none)'
  else
    @item[:tags].join(', ')
  end
end
