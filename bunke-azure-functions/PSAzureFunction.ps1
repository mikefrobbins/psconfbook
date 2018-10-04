# Supported query parameters:
  # tag

# Create an empty list to append results into
$ResultList = New-Object System.Collections.Generic.List[object]

# Set the URI, with or without a user-supplied tag
$BaseURI = 'https://blogs.msdn.microsoft.com/powershell'
If ($req_query_tag) {
    $BaseURI = "$BaseURI/tag/$req_query_tag"
}

Try {
    # Get the latest 10 posts (RSS feed default is 10 per page)
    $iwr = Invoke-WebRequest -Uri "$BaseURI/feed" -UseBasicParsing
} Catch {
    # Invoke-WebRequest is weird. Just silently fail
}

If ($iwr) {
    # Cast the RSS feed as XML
    [xml]$xml = $iwr.Content

    ForEach ($post in $xml.rss.channel.item) {
        # Assemble the most useful properties in an object
        $newObject = [PSCustomObject]@{
            Date        = $post.pubDate -as [DateTime]
            Title       = $post.title
            Description = $post.description.'#cdata-section'
            Link        = $post.link
        }

        # Append the object into the collection
        [void]$ResultList.Add($newObject)
    }

    # Return the objects in JSON format. Azure Functions likes Out-String
    $return = $ResultList | ConvertTo-Json | Out-String

    # By default, Azure Functions wants to output the contents of $res
    Out-File -Encoding Ascii -FilePath $res -inputObject $return
}
