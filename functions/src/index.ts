import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { OpenAI } from 'openai';
import { GoogleGenerativeAI } from '@google/generative-ai';
import * as cors from 'cors';
import * as express from 'express';
import * as helmet from 'helmet';
import { RateLimiterMemory } from 'rate-limiter-flexible';
import { v4 as uuidv4 } from 'uuid';
import * as validator from 'validator';
import * as moment from 'moment';

// Initialize Firebase Admin SDK
admin.initializeApp();

// Initialize AI services
const openai = new OpenAI({
  apiKey: functions.config().openai?.api_key || process.env.OPENAI_API_KEY,
});

const genAI = new GoogleGenerativeAI(
  functions.config().gemini?.api_key || process.env.GOOGLE_GEMINI_API_KEY
);

// Initialize Express app with middleware
const app = express();
app.use(helmet());
app.use(cors({ origin: true }));
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const rateLimiter = new RateLimiterMemory({
  keyGenerator: (req: express.Request) => req.ip,
  points: 10, // Number of requests
  duration: 60, // Per 60 seconds
});

// Interfaces
interface PrayerContext {
  moodLevel: number;
  category: string;
  timeOfDay: string;
  userPreferences?: {
    denomination?: string;
    language?: string;
    tone?: string;
    length?: string;
  };
  personalContext?: string;
}

interface AIResponse {
  content: string;
  model: string;
  tokensUsed: number;
  generationTime: number;
}

// Helper Functions
function validatePrayerRequest(data: any): PrayerContext | null {
  if (!data.moodLevel || !data.category || !data.timeOfDay) {
    return null;
  }

  if (typeof data.moodLevel !== 'number' || 
      data.moodLevel < 1 || data.moodLevel > 10) {
    return null;
  }

  if (!validator.isAlpha(data.category.replace(/\s/g, ''))) {
    return null;
  }

  return {
    moodLevel: data.moodLevel,
    category: validator.escape(data.category),
    timeOfDay: validator.escape(data.timeOfDay),
    userPreferences: data.userPreferences || {},
    personalContext: data.personalContext ? 
      validator.escape(data.personalContext) : undefined,
  };
}

function buildPrayerPrompt(context: PrayerContext): string {
  const { moodLevel, category, timeOfDay, userPreferences, personalContext } = context;
  
  let moodDescription = '';
  if (moodLevel <= 3) {
    moodDescription = 'struggling, needing comfort and hope';
  } else if (moodLevel <= 6) {
    moodDescription = 'seeking balance and inner peace';
  } else {
    moodDescription = 'feeling grateful and wanting to celebrate';
  }

  const denominationGuidance = userPreferences?.denomination 
    ? `with ${userPreferences.denomination} sensibilities` 
    : 'that is inclusive and non-denominational';

  const personalNote = personalContext 
    ? `\n\nPersonal context to consider: ${personalContext}` 
    : '';

  return `Create a heartfelt, compassionate prayer for someone who is ${moodDescription}.

Prayer Details:
- Category: ${category}
- Time of day: ${timeOfDay}
- Mood level: ${moodLevel}/10
- Spiritual approach: ${denominationGuidance}
- Tone: ${userPreferences?.tone || 'warm and supportive'}
- Length: ${userPreferences?.length || '2-3 paragraphs'}${personalNote}

Requirements:
- Be genuinely compassionate and understanding
- Use inclusive, accessible language
- Avoid denominational specifics unless requested
- Focus on healing, hope, and spiritual strength
- Make it personal and meaningful
- Appropriate for the current mood and circumstances

Create a prayer that truly speaks to someone's heart in this moment.`;
}

async function generateWithOpenAI(prompt: string): Promise<AIResponse> {
  const startTime = Date.now();
  
  try {
    const completion = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: 'You are a compassionate spiritual companion who creates personalized, inclusive prayers for healing and emotional support. Your prayers bring comfort, hope, and peace to people from all backgrounds and faiths.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      max_tokens: 500,
      temperature: 0.7,
      top_p: 0.9,
      frequency_penalty: 0.3,
      presence_penalty: 0.2,
    });

    const content = completion.choices[0]?.message?.content;
    if (!content) {
      throw new Error('No content generated from OpenAI');
    }

    return {
      content,
      model: 'gpt-4',
      tokensUsed: completion.usage?.total_tokens || 0,
      generationTime: Date.now() - startTime,
    };
  } catch (error) {
    console.error('OpenAI generation failed:', error);
    throw new functions.https.HttpsError('internal', 'AI prayer generation failed');
  }
}

async function generateWithGemini(prompt: string): Promise<AIResponse> {
  const startTime = Date.now();
  
  try {
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
    
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const content = response.text();

    if (!content) {
      throw new Error('No content generated from Gemini');
    }

    return {
      content,
      model: 'gemini-pro',
      tokensUsed: 0, // Gemini doesn't provide token usage in the same way
      generationTime: Date.now() - startTime,
    };
  } catch (error) {
    console.error('Gemini generation failed:', error);
    throw new functions.https.HttpsError('internal', 'AI prayer generation failed');
  }
}

// Main Cloud Functions

/**
 * Generate AI-powered personalized prayer
 */
export const generatePrayer = functions.https.onCall(async (data, context) => {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated', 
      'User must be authenticated to generate prayers'
    );
  }

  // Validate request data
  const prayerContext = validatePrayerRequest(data);
  if (!prayerContext) {
    throw new functions.https.HttpsError(
      'invalid-argument', 
      'Invalid prayer request data'
    );
  }

  const userId = context.auth.uid;

  try {
    // Build AI prompt
    const prompt = buildPrayerPrompt(prayerContext);
    
    // Try OpenAI first, fallback to Gemini
    let aiResponse: AIResponse;
    try {
      aiResponse = await generateWithOpenAI(prompt);
    } catch (openaiError) {
      console.log('OpenAI failed, trying Gemini fallback:', openaiError);
      aiResponse = await generateWithGemini(prompt);
    }

    // Create prayer document
    const prayerDoc = await admin.firestore().collection('prayers').add({
      userId,
      content: aiResponse.content,
      category: prayerContext.category,
      moodContext: prayerContext.moodLevel,
      timeOfDay: prayerContext.timeOfDay,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      source: 'ai_generated',
      metadata: {
        model: aiResponse.model,
        tokensUsed: aiResponse.tokensUsed,
        generationTime: aiResponse.generationTime,
        promptVersion: '1.0',
      },
      userPreferences: prayerContext.userPreferences,
      personalContext: prayerContext.personalContext,
    });

    // Log analytics
    await admin.firestore().collection('analytics').add({
      userId,
      event: 'prayer_generated',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      data: {
        prayerId: prayerDoc.id,
        category: prayerContext.category,
        moodLevel: prayerContext.moodLevel,
        model: aiResponse.model,
        generationTime: aiResponse.generationTime,
      },
    });

    return {
      prayerId: prayerDoc.id,
      content: aiResponse.content,
      category: prayerContext.category,
      moodContext: prayerContext.moodLevel,
      metadata: {
        model: aiResponse.model,
        generationTime: aiResponse.generationTime,
      },
    };

  } catch (error) {
    console.error('Prayer generation failed:', error);
    
    // Log error for monitoring
    await admin.firestore().collection('errors').add({
      userId,
      function: 'generatePrayer',
      error: error.message,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      context: prayerContext,
    });

    throw new functions.https.HttpsError(
      'internal', 
      'Failed to generate prayer. Please try again.'
    );
  }
});

/**
 * Analyze mood trends and detect potential crisis situations
 */
export const analyzeMoodTrends = functions.firestore
  .document('users/{userId}/moodEntries/{entryId}')
  .onCreate(async (snap, context) => {
    const { userId } = context.params;
    const newMoodEntry = snap.data();

    try {
      // Get recent mood entries (last 7 days)
      const sevenDaysAgo = moment().subtract(7, 'days').toDate();
      const recentEntries = await admin.firestore()
        .collection(`users/${userId}/moodEntries`)
        .where('timestamp', '>=', sevenDaysAgo)
        .orderBy('timestamp', 'desc')
        .limit(14)
        .get();

      const moods = recentEntries.docs.map(doc => doc.data().moodLevel as number);
      
      // Calculate analytics
      const averageMood = moods.reduce((sum, mood) => sum + mood, 0) / moods.length;
      const consecutiveLowMoods = calculateConsecutiveLowMoods(moods);
      const trendDirection = calculateTrendDirection(moods);
      
      // Crisis detection
      const isCrisisDetected = averageMood <= 3 && consecutiveLowMoods >= 3;
      const isHighRisk = averageMood <= 2 && consecutiveLowMoods >= 2;

      // Update user analytics
      await admin.firestore().doc(`users/${userId}`).set({
        analytics: {
          averageMood,
          consecutiveLowMoods,
          trendDirection,
          lastAnalysisUpdate: admin.firestore.FieldValue.serverTimestamp(),
          riskLevel: isHighRisk ? 'high' : isCrisisDetected ? 'moderate' : 'low',
        }
      }, { merge: true });

      // Trigger crisis support if needed
      if (isCrisisDetected) {
        await triggerCrisisSupport(userId, averageMood, isHighRisk);
      }

      console.log(`Mood analysis complete for user ${userId}. Average: ${averageMood}, Risk: ${isHighRisk ? 'high' : isCrisisDetected ? 'moderate' : 'low'}`);

    } catch (error) {
      console.error('Mood analysis failed:', error);
      
      await admin.firestore().collection('errors').add({
        userId,
        function: 'analyzeMoodTrends',
        error: error.message,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

/**
 * Send scheduled prayer notifications
 */
export const sendScheduledNotifications = functions.pubsub
  .schedule('every day 07:00')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    try {
      // Get users who opted in for morning notifications
      const users = await admin.firestore()
        .collection('users')
        .where('preferences.notifications.morning', '==', true)
        .where('fcmToken', '!=', null)
        .get();

      const notifications = users.docs.map(doc => {
        const userData = doc.data();
        return {
          token: userData.fcmToken,
          notification: {
            title: 'Good Morning 🌅',
            body: 'Start your day with a moment of hope and gratitude',
          },
          data: {
            type: 'morning_prayer',
            userId: doc.id,
          },
          android: {
            notification: {
              icon: 'healpray_notification',
              color: '#4ECDC4',
            },
          },
          apns: {
            payload: {
              aps: {
                category: 'PRAYER_REMINDER',
              },
            },
          },
        };
      });

      if (notifications.length > 0) {
        const response = await admin.messaging().sendAll(notifications);
        console.log(`Morning notifications sent: ${response.successCount} successful, ${response.failureCount} failed`);
      }

    } catch (error) {
      console.error('Scheduled notifications failed:', error);
    }
  });

// Helper functions
function calculateConsecutiveLowMoods(moods: number[]): number {
  let consecutive = 0;
  let maxConsecutive = 0;
  
  for (const mood of moods) {
    if (mood <= 3) {
      consecutive++;
      maxConsecutive = Math.max(maxConsecutive, consecutive);
    } else {
      consecutive = 0;
    }
  }
  
  return maxConsecutive;
}

function calculateTrendDirection(moods: number[]): 'improving' | 'declining' | 'stable' {
  if (moods.length < 3) return 'stable';
  
  const recent = moods.slice(0, 3).reduce((sum, mood) => sum + mood, 0) / 3;
  const older = moods.slice(-3).reduce((sum, mood) => sum + mood, 0) / 3;
  
  const difference = recent - older;
  
  if (difference > 0.5) return 'improving';
  if (difference < -0.5) return 'declining';
  return 'stable';
}

async function triggerCrisisSupport(userId: string, averageMood: number, isHighRisk: boolean): Promise<void> {
  try {
    // Get user data for notification
    const userDoc = await admin.firestore().doc(`users/${userId}`).get();
    const userData = userDoc.data();

    // Send immediate support notification
    if (userData?.fcmToken) {
      await admin.messaging().send({
        token: userData.fcmToken,
        notification: {
          title: 'We\'re here for you 💙',
          body: 'You\'re not alone. Tap for support resources and caring guidance.',
        },
        data: {
          type: 'crisis_support',
          averageMood: averageMood.toString(),
          riskLevel: isHighRisk ? 'high' : 'moderate',
        },
        android: {
          priority: 'high',
          notification: {
            icon: 'healpray_crisis',
            color: '#FF6B6B',
            priority: 'high',
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
          },
          payload: {
            aps: {
              category: 'CRISIS_SUPPORT',
              sound: 'default',
            },
          },
        },
      });
    }

    // Log crisis event for follow-up
    await admin.firestore().collection('crisisEvents').add({
      userId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      averageMood,
      riskLevel: isHighRisk ? 'high' : 'moderate',
      notificationSent: true,
      followUpScheduled: true,
    });

    console.log(`Crisis support triggered for user ${userId} (avg mood: ${averageMood}, high risk: ${isHighRisk})`);

  } catch (error) {
    console.error('Crisis support trigger failed:', error);
  }
}

// Export the Express app as a Cloud Function
export const api = functions.https.onRequest(app);
