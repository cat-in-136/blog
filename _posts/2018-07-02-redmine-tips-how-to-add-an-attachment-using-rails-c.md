---
layout: post
title: 'Redmine Tips: How to add an attachment using rails c'
date: '2018-07-02T23:39:13+09:00'
tags:
- redmine
- howto
- チラシの裏
---
This post describes how to add an attachment (file) to an issue using `rails c` (rails console).
Note that it is assumed that `issue` is already present.
This would work even if the plugins such as [redmine_s3] installed.

[redmine_s3]: https://www.redmine.org/plugins/redmine_s3

### Add an attachment to an issue w/ journal

```ruby
# issue, user, filepath are assumed to be already set.
File.open(filepath, "rb") do |f|
  # f.flock(File::LOCK_SH)
  attachment = Attachment.new(
    :file => ActionDispatch::Http::UploadedFile.new(
      :tempfile => f,
      :filename => File.basename(filepath),
      :type => "image/jpeg",
    ),
    :author => author,
  )
  issue.init_journal(author)
  issue.attachments << attachment
  issue.save
end
```

### Add an attachment to an issue w/o journal

```ruby
# issue, user, filepath are assumed to be already set.
File.open(filepath, "rb") do |f|
  # f.flock(File::LOCK_SH)
  Attachment.create!(
    :file => ActionDispatch::Http::UploadedFile.new(
      :tempfile => f,
      :filename => File.basename(filepath),
      :type => "image/jpeg",
    ),
    :author => author,
    :container => issue,
  )
end
```

Note: Unlike "w/ journal" case, you need to set `:container` to the issue.
