function Get-AzureBlogUpdates {
    <#
      .SYNOPSIS
      Retrieves the latest Updates of Azure, from the Azure Blog RSS feed.
      .DESCRIPTION
      Retrieves the latest Updates of Azure, from the Azure Blog RSS feed.
      .NOTES
      Version:        1.0
      Author:         Luke Murray (Luke.Geek.NZ) 
      Website: https://luke.geek.nz/keep-up-to-date-with-latest-changes-on-azure-using-powershell
      Creation Date:  03.04.21
      Purpose/Change: 
      03.04.21 - Intital script development
      .EXAMPLE
      Get-AzureBlogUpdate
  #>
  #Retrieving RSS Feed Content - as XML, then converting into PSObject
    $xml = [xml](Invoke-WebRequest -Uri 'https://timesofindia.indiatimes.com/rssfeeds/66949542.cms').content
    $Array = @()
    foreach ($y in $xml.rss.channel.selectnodes('//item'))
    {
        $PSObject = New-Object -TypeName PSObject
        $Date = [datetime]$y.pubdate
$PSObject | Add-Member NoteProperty 'title'       $y.title       
$PSObject | Add-Member NoteProperty 'description' $y.description         
$PSObject | Add-Member NoteProperty 'link'        $y.link        
$PSObject | Add-Member NoteProperty 'guid'        $y.guid        
$PSObject | Add-Member NoteProperty 'pubDate'     $y.pubDate     
$PSObject | Add-Member NoteProperty 'creator'     $y.creator     
$PSObject | Add-Member NoteProperty 'enclosure'   $y.enclosure   
    
    
        $Array += $PSObject
    } 
    #Some article had multiple categories, to make it easier for reporting, joined the categories together and got rid of duplicates.

    $results = @()
    ForEach ($item in $Array) {
        $Category = Foreach ($title in $item.Title)
        {
            $results += [pscustomobject]@{
                #'Title'          = $item.Title
                #'Category'       = $item.Category -join ',' | Select-Object -Unique
                #'Published Date' = $item.Date
                #'Description'    = $item.Description
                #'Link'           = $item.Link

                'title'       = $y.title       
                'description' = $y.description 
                'link'        = $y.link        
                'guid'        = $y.guid        
                'pubDate'     = $y.pubDate     
                'creator'     = $y.creator     
                'enclosure'   = $y.enclosure   
            }
        }
    }
    $results
}

Get-AzureBlogUpdates

