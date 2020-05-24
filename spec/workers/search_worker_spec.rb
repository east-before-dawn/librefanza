require "rails_helper"

RSpec.describe SearchWorker, type: :worker do
  it "searches fanza first" do
    id = generate :normalized_id

    expect(Fanza::Api).to receive(:item_list).with(id).and_call_original
    subject.perform id
  end

  it "searches javlibrary next" do
    id = generate :normalized_id

    expect(Fanza::Api).to receive(:item_list).with(id).and_return([].each)

    url = generate(:url)
    html = [generate(:url), "<html></html>"]
    expect(Javlibrary::Api).to receive(:search).with(id).and_yield(url, html)
    expect(JavlibraryPage).to receive(:create).with(url: url, raw_html: html)

    subject.perform id
  end

  it "only searches javlibrary when necessary" do
    item = create :javlibrary_item
    id = item.normalized_id

    expect(Fanza::Api).to receive(:item_list).with(id).and_return([].each)
    expect(Javlibrary::Api).not_to receive(:search)

    subject.perform id
  end
end
