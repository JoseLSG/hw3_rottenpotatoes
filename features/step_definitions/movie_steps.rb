# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    #Movie.create!({:title => movie[:title], :rating => movie[:rating], :release_date => movie[:title] })
    Movie.create!(movie)
  end
end

Given /I check (all |no )ratings/ do |check|
  Movie.all_ratings.each do |rating|
    steps %Q{ When I check "#{rating}" checkbox } if check.strip == "all"
    steps %Q{ When I uncheck "#{rating}" checkbox } if check.strip == "no"
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  # puts "****************************"
  # puts page.body
  regexp = /#{e1}.*#{e2}/m #  /m means match across newlines
  page.body.should =~ regexp
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  rating_list.split(", ").each do |rating|
    if uncheck
      steps %Q{ When I uncheck "#{rating}" checkbox }
    else
      steps %Q{ When I check "#{rating}" checkbox }
    end
  end
end

When /^(?:|I )(un)?check everything but the following: (.*)/ do |uncheck, list|
  movie_ratings = Movie.all_ratings

  list.split(", ").each do |rating|
    movie_ratings.delete_if{|i| i == rating}
  end

  movie_ratings.each do |rating|
    steps %Q{ When I uncheck "#{rating}" checkbox }
  end
end

When /I (un)?check "(.*)" checkbox/ do |uncheck, option|
  if uncheck
    steps %Q{ When I uncheck "ratings_#{option}" }
  else
    steps %Q{ When I check "ratings_#{option}" }
  end
end

Then /^(?:|I )should (not )?see "(.*)" in table "(.*)"/ do |not_see, text, element_id|
  regexp = /<td>#{text}<\/td>/m #  /m means match across newlines
  if not_see
    page.body.should_not =~ regexp
  else
    page.body.should =~ regexp
  end
end

Then /^(?:|I )should not see the rest in table "(.*)"/ do |element_id|
  Movie.all_ratings.each do |rating|
    next if rating == "PG" or rating == "R"
    steps %Q{ Then I should not see "#{rating}" in table "#{element_id}" }
  end
end

Then /^(?:|I )should only see in table "(.*)" the following ratings: (.*)/ do |table, list|
  list.split(", ").each do |rating|
    steps %Q{ Then I should see "#{rating}" in table "#{table}" }
  end
  steps %Q{ And I should not see the rest in table "#{table}" }
end

Then /I should see (all |none )of the movies/ do |check|
  if check.strip == "all"
    value = Movie.count 
  elsif check.strip == "none"
    value = 0
  end
  page.all('table#movies tr').count.should == value + 1 # movie rows + 1 header row
end