import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const posts = await getCollection('blog');
  posts.sort((a, b) => {
    const da = a.data.date ? new Date(a.data.date).getTime() : 0;
    const db = b.data.date ? new Date(b.data.date).getTime() : 0;
    return db - da;
  });

  return rss({
    title: 'Freejolitos',
    description: 'Nodo de cultura hacker en español. Conocimiento libre. Red sin dueño.',
    site: context.site,
    items: posts.map(post => ({
      title: post.data.title,
      pubDate: post.data.date,
      description: post.data.description,
      link: `/blog/${post.data.category}/${post.slug}/`,
    })),
    customData: `<language>es</language>`,
  });
}
